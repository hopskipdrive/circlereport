# regular Ruby class. Validates options, collects data, produces report.
class Reporter
  attr_reader :errors

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
    @errors = []
    @errors << "You can't use both capture and input at the same time" if @capture && @input_file
    @errors << "Circle Token missing. Use --token or environment variable 'CIRCLETOKEN'." if @token.empty?
  end

  def report
    puts "Start Date: #{@start_date}"
    puts "Reading from file #{@input_file}" if @input_file
    circle_json = @input_file ? file_data : circle_data
    return unless @errors.size.zero?

    success = 0.0
    fails = 0.0
    results = scan_results(circle_json)
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

  def scan_results(circle_json)
    # results is a hash where the date is the key and the value is a hash {#success, #fail}
    results = {}
    range = @start_date..@start_date + 6
    circle_json.each do |build|
      commit_date = Date.parse(build['committer_date'])
      next unless range.include?(commit_date)

      date_key = commit_date.to_s
      results[date_key] = { success: 0, fail: 0 } unless results.key?(date_key)
      if %w[success fixed].include?(build['status'])
        results[date_key][:success] += 1
      else
        results[date_key][:fail] += 1
      end
    end
    results
  end

  def circle_data
    limit = 100
    url = "https://circleci.com/api/v1/project/#{@account}/#{@repository}/tree/#{@branch}?shallow=true&limit=#{limit}"
    response = ''
    URI.open(url, 'Circle-Token' => @token, 'Accept' => 'Application/json') do |f|
      f.each_line { |line| response += line }
    end

    File.open("circle_data_#{DateTime.now}.json", 'w') { |file| file.write(response) } if @capture
    JSON.parse(response)
  rescue StandardError => e
    errors << "Error retrieving from CircleCI:\n    #{e}.\n'"\
                "    '404 Not Found' could indicate a problem with your Circle Token."
  end

  def file_data
    response = ''
    File.open @input_file do |f|
      f.each_line { |line| response += line }
    end
    JSON.parse(response)
  rescue StandardError => e
    errors << "Error reading from file: #{@input_file}\n    #{e}"
  end
end
