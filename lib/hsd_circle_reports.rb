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
         'for the 7 days commencing [date] (defaults to Today - 7).'

    option :branch, type: :string, desc: 'the branch to report on (default: \'develop\')'
    option :capture, type: :boolean, desc: 'save the output from CircleCI in a JSON file'
    option :input, type: :string, desc: 'read data from this file instead of calling the CircleCI API'
    option :token, type: :string, desc: 'Your API token for CircleCI'
    option :start, type: :string, desc: 'Start date in YYYY-MM-DD format (default: Today - 7 days.'
    option :account, type: :string, desc: 'CircleCI account name.'
    option :repository, type: :string, desc: 'The VCS repository name you test on CircleCI.'

    def build_stats
      reporter = Reporter.new(options)
      unless reporter.errors.size.zero?
        reporter.errors.each { |err| puts err }
        exit 1
      end

      reporter.report
      return if reporter.errors.size.zero?

      reporter.errors.each { |err| puts err }
      exit 2
    end
  end
end
