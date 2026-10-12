# frozen_string_literal: true

module Etcetera
  module AppStrategy
    # This is the strategy created by Apple for use on macOS and iOS devices. It is always used by GUI apps on macOS, and is sometimes used by command-line applications there too. iOS only has GUIs, so all iOS applications follow this strategy. The specification is available {here}[https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW1].
    #
    #   require "etcetera"
    #
    #   app_strategy = Etcetera::AppStrategy::Apple.new(Etcetera::AppStrategy::AppStrategyArgs.new(
    #     top_level_domain: "org",
    #     author: "Acme Corp",
    #     app_name: "Frobnicator Plus"
    #   ))
    #
    #   home_dir = Etcetera.home_dir
    #
    #   app_strategy.home_dir == home_dir # => true
    #   app_strategy.config_dir.relative_path_from(home_dir) # => #<Pathname:Library/Preferences/org.acme-corp.Frobnicator-Plus>
    #   app_strategy.data_dir.relative_path_from(home_dir) # => #<Pathname:Library/Application Support/org.acme-corp.Frobnicator-Plus>
    #   app_strategy.cache_dir.relative_path_from(home_dir) # => #<Pathname:Library/Caches/org.acme-corp.Frobnicator-Plus>
    #   app_strategy.state_dir # => nil
    #   app_strategy.runtime_dir # => nil
    Apple = Data.define(:base_strategy, :bundle_id) do
      include AppStrategy
      include FieldOrder

      class << self
        alias_method :from_fields, :new
        private :from_fields

        # Create a new Apple AppStrategy
        def new(args) = from_fields(base_strategy: BaseStrategy::Apple.new, bundle_id: args.bundle_id)
      end

      private :base_strategy, :bundle_id

      def home_dir = base_strategy.home_dir

      def config_dir = base_strategy.config_dir.join(bundle_id)

      def data_dir = base_strategy.data_dir.join(bundle_id)

      def cache_dir = base_strategy.cache_dir.join(bundle_id)

      def state_dir = nil

      def runtime_dir = nil
    end
  end
end
