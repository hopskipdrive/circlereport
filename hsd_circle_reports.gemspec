# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hsd_circle_reports/version'

Gem::Specification.new do |spec|
  spec.name          = 'hsd_circle_reports'
  spec.version       = HsdCircleReports::VERSION
  spec.authors       = ['Ian Hall']
  spec.email         = ['ianh.99@gmail.com']

  spec.summary       = 'Generate reports from the CircleCI API.'
  spec.description   = 'Calls the CircleCI API, retrieves information about build success rate.'
  spec.homepage      = 'https://www.hopskipdrive.com'
  spec.license       = 'MIT'

  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.' unless spec.respond_to?(:metadata)

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  #     to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  spec.metadata['homepage_uri'] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.86'
  spec.add_dependency 'thor', '~> 1.0'
end
