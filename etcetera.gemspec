# frozen_string_literal: true

require_relative "lib/etcetera/version"

Gem::Specification.new do |spec|
  spec.name = "etcetera"
  spec.version = Etcetera::VERSION
  spec.authors = ["Kerrick Long"]
  spec.email = ["me@kerricklong.com"]

  spec.summary = "An unopinionated library for obtaining configuration, data, cache, & other directories"
  spec.description = <<~DESCRIPTION
    An unopinionated library for obtaining configuration, data, cache, & other
    directories. Etcetera supports the XDG base directory specification, Apple's
    Standard Directories, Windows' Known Folder Locations, and the Unix
    single-folder convention, and lets you choose which to follow.
  DESCRIPTION
  spec.homepage = "https://github.com/Kerrick/etcetera_rb"
  spec.required_ruby_version = ">= 4.0.0"
  spec.licenses = ["MIT", "Apache-2.0"]

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/ruby/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/etcetera"

  # Specify which files are added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # The crate depends on windows-sys to call the Known Folder API; this gem
  # calls it through Fiddle, a bundled gem since Ruby 4.0.
  spec.add_dependency "fiddle", "~> 1.1"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
