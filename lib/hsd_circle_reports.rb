# frozen_string_literal: true

require 'hsd_circle_reports/version'

# HsdCircleReports is the main (only) module
module HsdCircleReports
  class Error < StandardError; end

  require 'hsd_circle_reports/version'
  require 'hsd_circle_reports/reporter'
  require 'thor'
  require 'open-uri'
  require 'json'
  require 'time'

  # Report inherits from Thor and contains the build_stats method, where the main logic is defined
  class Report < Thor
    def self.exit_on_failure?
      true
    end

    desc 'build_stats',
         'Retrieves run data from CircleCI and displays #successes and #others'\
         'for the 7 days commencing [date] (defaults to Today - 7)'

    option :account, type: :string, desc: 'Your CircleCI account name', default: 'hopskipdrive'
    option :branch, type: :string, desc: 'The branch to report on', default: 'develop'
    option :repository, type: :string, desc: 'The VCS repository to report on', default: 'rails-api'
    option :start, type: :string, desc: 'Start date in YYYY-MM-DD format. Default: Today - 7 days'
    option :capture, type: :boolean, desc: 'Save the output from CircleCI in a JSON file', default: false
    option :input, type: :string, desc: 'Read data from this file instead of calling the CircleCI API'
    option :token, type: :string, desc: 'Your API token for CircleCI'

    def build_stats
      reporter = Reporter.new(options)
      unless reporter.errors.size.zero?
        reporter.errors.each { |err| puts err }
        exit 1
      end

      results, = reporter.report
      unless reporter.errors.size.zero?
        reporter.errors.each { |err| puts err }
        exit 2
      end

      results.each { |r| puts r }
    end

    default_task :build_stats
  end
end
