# frozen_string_literal: true

require_relative "lib/slimer/version"

Gem::Specification.new do |spec|
  spec.name          = "slimer"
  spec.version       = Slimer::VERSION
  spec.authors       = ["Valentino Stoll"]
  spec.email         = ["v@codenamev.com"]

  spec.summary       = "A minimalist consumer with an endless appetite."
  spec.description   = "Slimer is an app that allows you to consume any data with ease"
  spec.homepage      = "https://github.com/codenamev/slimer"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/codenamev/slimer"
  spec.metadata["changelog_uri"] = "https://github.com/codenamev/slimer"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features|examples)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sequel", ">= 5.40"
  spec.add_dependency "sidekiq", ">= 6.1"
  # Sidekiq depends on rack, but include it in case they drop support
  spec.add_dependency "rack", "~> 2.0"
  spec.add_dependency "rake", "~> 13.0"

  spec.add_development_dependency "minitest-stub-const"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "sqlite3"
  spec.metadata = {
    "rubygems_mfa_required" => "true"
  }
end
