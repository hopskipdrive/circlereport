require 'bundler/setup'
require 'hsd_circle_reports'
require 'climate_control'
require 'webmock'
require 'vcr'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = 'spec/.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  VCR.configure do |c|
    c.cassette_library_dir = 'spec/vcr'
    c.hook_into :webmock
  end

  def capture_stdout(&blk)
    $stdout = fake = StringIO.new
    blk.call
    fake.string
  ensure
    $stdout.reopen
  end
end
