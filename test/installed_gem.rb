# frozen_string_literal: true

# Checks the packaged gem as it is installed from its .gem file, rather than as
# it is loaded from this checkout. Run it from outside the checkout, without
# Bundler, once the gem is installed.
require "etcetera"

spec = Gem.loaded_specs["etcetera"] or abort "etcetera was not loaded from an installed gem"
%w[LICENSE-MIT LICENSE-APACHE LICENSE-WINDOWS-SYS].each do |license|
  abort "#{license} is missing from the gem" unless File.exist?(File.join(spec.full_gem_path, license))
end

# With APPDATA gone, the Windows strategy asks the Known Folder API.
ENV.delete("APPDATA")
appdata = Etcetera::BaseStrategy::Windows.new.data_dir
abort "#{appdata} is not absolute" unless appdata.absolute?

args = Etcetera::AppStrategyArgs.new(top_level_domain: "org", author: "Acme Corp", app_name: "Frobnicator Plus")
strategies = [
  Etcetera.choose_base_strategy,
  Etcetera::BaseStrategy.choose_native_strategy,
  *%i[Apple Windows Xdg].map { Etcetera::BaseStrategy.const_get(it).new },
  Etcetera.choose_app_strategy(args),
  Etcetera::AppStrategy.choose_native_strategy(args),
  *%i[Apple Unix Windows Xdg].map { Etcetera::AppStrategy.const_get(it).new(args) }
]
strategies.each do |strategy|
  %i[home_dir config_dir data_dir cache_dir state_dir runtime_dir].each { strategy.public_send(it) }
  puts strategy.inspect
end
puts "etcetera #{spec.version} works as installed from #{spec.full_gem_path}"
