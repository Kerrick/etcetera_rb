# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in etcetera.gemspec
gemspec

gem "irb"
gem "rake", "~> 13.0"

gem "minitest", "~> 5.16"

gem "rubocop", "~> 1.21"

# Fiddle stopped being a default gem in Ruby 4.0, and Bundler hides bundled
# gems from anything that has not asked for them. Ask for the copy that
# ships with this Ruby, pinned to its own version, so nothing is ever
# downloaded or compiled.
fiddle = Gem::Specification.find_all_by_name("fiddle").reject(&:default_gem?).max_by(&:version)
gem "fiddle", fiddle.version if fiddle
