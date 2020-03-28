#!/usr/bin/env ruby
require 'thor'
require 'open-uri'
require 'json'
require 'time'

class CircleReport < Thor
  def self.exit_on_failure?
    true
  end

  desc "rpt", "Retrieves run data from Circle and displays #successes and #others from the 7 days commencing [date]"
  def rpt(wc_date)
    puts wc_date
    # json_arr = circle_data
    json_arr = data_from_file
    puts "Number of entries: #{json_arr.size}"
    puts "Keys: #{json_arr[0].keys}"
    json_arr.each do |build|
      commit_date = Time.parse(build['committer_date'])
      puts "#{commit_date} #{build['status']}"
    end
  end

  private

  def circle_data
    limit = 100
    url = "https://circleci.com/api/v1/project/hopskipdrive/rails-api/tree/develop?shallow=true&limit=#{limit}"
    token = ENV['CIRCLETOKEN']

    response = ''
    open(url,
         "Circle-Token" => token,
         "Accept" => "Application/json") { |f|
      f.each_line { |line| response = response + line }
    }

    JSON.parse(response)
  end

  def data_from_file
    response = ''
    open './develop1.json' do |f|
      f.each_line { |line| response = response + line }
    end
    JSON.parse(response)
  end
end

CircleReport.start
