# Module
module HsdCircleReports
  # regular Ruby class. Validates options, collects data, produces report.
  class Reports
    attr_reader :branch, :capture, :input_file, :token, :start_date, :account, :repository

    def initialize(options)
      @account = options[:account] || 'hopskipdrive'
      @branch = options[:branch] || 'develop'
      @capture = options[:capture] || false
      @input_file = options[:input]
      @repository = options[:repository] || 'rails-api'
      @start_date = if options[:start]
                      Date.parse(options[:start])
                    else
                      Date.today - 7
                    end
      @token = options[:token] || ENV['CIRCLETOKEN']
    end

    def check_options
      exit_code = 0
      errors = []
      if @capture && @input_file
        errors << 'You can\'t use both capture and input at the same time'
        exit_code = 1
      end

      if @token.empty?
        errors << 'No Circle Token supplied. Use command line --token or environment variable \'CIRCLETOKEN\'.'
        exit_code = 1
      end
      [exit_code, errors]
    end

    def collect
      json_arr, errors = @input_file ? file_data : circle_data
      return [1, errors] if errors.size.positive?

      [json_arr, []]
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

    private

    def circle_data
      limit = 100
      url = "https://circleci.com/api/v1/project/#{@account}/#{@repository}/tree/#{@branch}?shallow=true&limit=#{limit}"
      response = ''
      URI.open(url, 'Circle-Token' => @token, 'Accept' => 'Application/json') do |f|
        f.each_line { |line| response += line }
      end

      File.open("circle_data_#{DateTime.now}.json", 'w') { |file| file.write(response) } if @capture
      [JSON.parse(response), []]
    rescue StandardError => e
      [{}, ["Error retrieving from CircleCI: #{e}.\n'404 Not Found' could indicate a problem with your Circle Token."]]
    end

    def file_data
      response = ''
      File.open @input_file do |f|
        f.each_line { |line| response += line }
      end
      [JSON.parse(response), []]
    rescue StandardError => e
      [{}, ["Error reading from file: #{@input_file}\n#{e}"]]
    end
  end
end
