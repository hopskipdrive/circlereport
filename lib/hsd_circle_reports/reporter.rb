# regular Ruby class. Validates options, collects data, produces report.
class Reporter
  attr_reader :errors, :report_period

  def initialize(options)
    @errors = []
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
    @report_period = @start_date..@start_date + 6
    @token = options[:token] || ENV['CIRCLETOKEN']
    if (@token.nil? || @token.empty?) && !@input_file
      @errors << "Circle Token missing. Use --token or environment variable 'CIRCLETOKEN'."
    end
    @errors << "You can't use both capture and input at the same time" if @capture && @input_file
  end

  def report
    circle_json = @input_file ? file_data : circle_data
    return unless @errors.size.zero?

    lines = []
    results = { success: 0.0, fails: 0.0 }
    lines << "Report Period: #{@report_period}"
    lines << "Reading from file #{@input_file}" if @input_file

    scan_results(circle_json).each do |date_key, value|
      lines << "Date: #{date_key} Successful builds: #{value[:success]}, failing builds: #{value[:fail]}"
      results[:success] += value[:success]
      results[:fails] += value[:fail]
    end
    lines << "\nPassing builds: #{results[:success].round(0)}"\
             ". Failing builds: #{results[:fails].round(0)}"

    if results[:success].positive? && results[:fails].positive?
      total_builds = results[:success] + results[:fails]
      results[:percent_success] = ((results[:success] / total_builds) * 100).round(2)
      results[:percent_fails] = ((results[:fails] / total_builds) * 100).round(2)
      lines << "Percentage succeeding: #{results[:percent_success]}"
      lines << "Percentage failing: #{results[:percent_fails]}"
    end
    [lines, results]
  end

  private

  def scan_results(circle_json)
    # results is a hash where the date is the key and the value is a hash {#success, #fail}
    results = {}
    circle_json.each do |build|
      commit_date = Date.parse(build['committer_date'])
      next unless @report_period.include?(commit_date)

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
    errors << "Error retrieving from CircleCI:\n"\
              "    #{e}.\n"\
              '    404 Not Found may indicate a problem with your Circle Token.'
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
