# frozen_string_literal: true

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

    def self.generate_default_date
      (Date.today - 7).strftime('%F')
    end
    default_date = generate_default_date

    desc 'build_stats',
         'Retrieves run data from CircleCI and displays #successes and #fails '\
         'for the 7 days commencing [date]'

    option :account, {
      type: :string,
      desc: 'Your CircleCI account name',
      default: 'hopskipdrive',
      aliases: %w[-a]
    }
    option :branch, {
      type: :string,
      desc: 'The branch to report on',
      default: 'develop',
      aliases: %w[-b]
    }
    option :repository, {
      type: :string,
      desc: 'The VCS repository to report on',
      default: 'rails-api',
      aliases: %w[-r]
    }
    option :start, {
      type: :string,
      desc: 'Start date in YYYY-MM-DD format',
      default: default_date,
      aliases: %w[-d]
    }
    option :capture, {
      type: :boolean,
      desc: 'Save the output from CircleCI in a JSON file',
      default: false,
      aliases: %w[-c]
    }
    option :input, {
      type: :string,
      desc: 'Read data from this file instead of calling the CircleCI API',
      aliases: %w[-i]
    }
    option :token, {
      type: :string,
      desc: 'Your API token for CircleCI',
      aliases: %w[-t]
    }

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
