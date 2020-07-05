# frozen_string_literal: true

require 'hsd_circle_reports/version'

# HsdCircleReports is the main (only) module
module HsdCircleReports
  class Error < StandardError; end

  require 'hsd_circle_reports/version'

  class Error < StandardError; end

  require 'thor'
  require 'open-uri'
  require 'json'
  require 'time'

  # Report inherits from Thor and contains the rpt method, where the main logic is defined
  class Report < Thor
    def self.exit_on_failure?
      true
    end

    desc 'rpt',
         'Retrieves run data from CircleCI and displays #successes and #others'\
         'for the 7 days commencing [date] (defaults to Today - 7).'

    option :branch, type: :string, desc: 'the branch to report on (default: \'develop\')'
    option :capture, type: :boolean, desc: 'save the output from CircleCI in a JSON file'
    option :input, type: :string, desc: 'read data from this file instead of calling the CircleCI API'
    option :token, type: :string, desc: 'Your API token for CircleCI'
    option :start, type: :string, desc: 'Start date in YYYY-MM-DD format (default: Today - 7 days.'

    def rpt
      if options[:capture] && options[:input]
        puts 'You can\'t use both capture and input at the same time'
        exit 1
      end

      token = options[:token] || ENV['CIRCLETOKEN']
      if token.empty?
        puts 'No Circle Token supplied. Use command line --token or environment variable \'CIRCLETOKEN\'.'
        exit 1
      end

      start_date = if options[:start]
                     Date.parse(options[:start])
                   else
                     Date.today - 7
                   end
      puts "Start Date: #{start_date}"
      puts "Reading from file #{options[:input]}" if options[:input]

      branch = options[:branch] || 'develop'

      json_arr = options[:input] ? data_from_file(options[:input]) : circle_data(branch, token, options[:capture])
      exit 1 unless json_arr

      report(scan_results(json_arr, start_date))
    end

    private

    def report(results)
      success = 0.0
      fails = 0.0
      results.each do |date_key, value|
        puts "Date: #{date_key} Successful builds: #{value[:success]} other builds: #{value[:fail]}"
        success += value[:success]
        fails += value[:fail]
      end
      puts "\nTotal successful builds: #{success.round(0)}, total failing builds: #{fails.round(0)}"
      percent_success = (success / (success + fails)) * 100
      percent_fails = (fails / (success + fails)) * 100
      puts "Percentage succeeding: #{percent_success.round(2)}" unless success.zero?
      puts "Percentage failing: #{percent_fails.round(2)}" unless fails.zero?
    end

    def scan_results(arr, start)
      # output is a hash where the date is the key and the value is a hash {#success, #fail}
      out = {}
      range = start..start + 6
      arr.each do |build|
        commit_date = Date.parse(build['committer_date'])
        next unless range.include?(commit_date)

        date_key = commit_date.to_s
        if out.key?(date_key)
          if %w[success fixed].include?(build['status'])
            out[date_key][:success] += 1
          else
            out[date_key][:fail] += 1
          end
        else
          out[date_key] = if %w[success fixed].include?(build['status'])
                            { success: 1, fail: 0 }
                          else
                            { success: 0, fail: 1 }
                          end
        end
      end
      out
    end

    def circle_data(branch, token, capture)
      limit = 100
      url = "https://circleci.com/api/v1/project/hopskipdrive/rails-api/tree/#{branch}?shallow=true&limit=#{limit}"
      response = ''
      URI.open(url, 'Circle-Token' => token, 'Accept' => 'Application/json') do |f|
        f.each_line { |line| response += line }
      end

      File.open("circle_data_#{DateTime.now}.json", 'w') { |file| file.write(response) } if capture
      JSON.parse(response)
    rescue StandardError => e
      puts "Error retrieving from CircleCI: #{e}.\n'404 Not Found' could indicate a problem with your Circle Token."
    end

    def data_from_file(filename)
      response = ''
      File.open filename do |f|
        f.each_line { |line| response += line }
      end
      JSON.parse(response)
    rescue StandardError => e
      puts "Error reading from file: #{filename}\n#{e}"
    end
  end
end
