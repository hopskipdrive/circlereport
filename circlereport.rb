#!/usr/bin/env ruby
require 'thor'
require 'open-uri'
require 'json'
require 'time'

class CircleReport < Thor
  def self.exit_on_failure?
    true
  end

  desc"rpt",
      "Retrieves run data from Circle and displays #successes and #others for the 7 days commencing [date] (defaults to Today - 7)."

  option :capture, type: :boolean, desc: 'save the output from CircleCI in a JSON file'
  option :input, type: :string, desc: 'read data from this file instead of calling the CircleCI endpoint'
  option :token, type: :string, desc: 'Your API token for CircleCI'

  def rpt(wc_date = '')
    if options[:capture] && options[:input]
      puts "You can't use both capture and input at the same time"
      exit 1
    end

    token = options[:token] || ENV['CIRCLETOKEN']
    if token.empty?
      puts "No Circle Token supplied. Use command line --token or environment variable 'CIRCLETOKEN'."
      exit 1
    end

    if wc_date.empty?
      start_date = Date.today - 7
    else
      start_date = Date.parse(wc_date)
    end
    puts "Date: #{start_date}"

    json_arr = options[:input] ? data_from_file(options[:input]) : circle_data(token, options[:capture])
    exit 1 unless json_arr
    results = scan_results(json_arr, start_date)

    success = 0.0
    fails = 0.0
    results.each do |k, v|
      puts "Date: #{k} Successful builds: #{v[0]} other builds: #{v[1]}"
      success = success + v[0]
      fails = fails + v[1]
    end
    puts "\nTotal successful builds: #{success.round(0)}, total failing builds: #{fails.round(0)}"
    perc_succ = (success / (success + fails)) * 100
    perc_fails = (fails / (success + fails)) * 100
    puts "Percentage succeeding: #{perc_succ.round(2)}" unless success.zero?
    puts "Percentage failing: #{perc_fails.round(2)}" unless fails.zero?
  end

  private

  def scan_results(arr, start)
    # output is a hash where the date is the key and the value is an array [#successes, #others]
    out = {}
    range = start..start + 6
    arr.each do |build|
      commit_date = Date.parse(build['committer_date'])
      if range === commit_date
        out_key = commit_date.to_s
        if out.has_key?(out_key)
          if build['status'] == 'success' || build['status'] == 'fixed'
            sc = [out[out_key][0] + 1, out[out_key][1]]
          else
            sc = [out[out_key][0], out[out_key][1] + 1]
          end
          out[out_key] = sc
        else
          if build['status'] == 'success' || build['status'] == 'fixed'
            out[out_key] = [1, 0]
          else
            out[out_key] = [0, 1]
          end
        end
      end
    end
    out
  end

  def circle_data(token, capture)
    limit = 100
    url = "https://circleci.com/api/v1/project/hopskipdrive/rails-api/tree/develop?shallow=true&limit=#{limit}"

    response = ''
    open(url,
         "Circle-Token" => token,
         "Accept" => "Application/json") { |f|
      f.each_line { |line| response = response + line }
    }

    File.open("circle_data_#{DateTime.now}.json", 'w') { |file| file.write(response) } if capture
    JSON.parse(response)
  rescue StandardError => error
    puts "Error retrieving from CircleCI: #{error}.\n'404 Not Found' could indicate a problem with your Circle Token."
  end

  def data_from_file(filename)
    response = ''
    open filename do |f|
      f.each_line { |line| response = response + line }
    end
    JSON.parse(response)
  rescue StandardError => error
    puts "Error reading from file: #{filename}\n#{error}"
  end
end

CircleReport.start
