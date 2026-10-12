# frozen_string_literal: true

module Etcetera
  module AppStrategy
    # This strategy has no standard or official specification. It has arisen over time through hundreds of Unixy tools. Vim and Cargo are notable examples whose configuration/data/cache directory layouts are similar to those created by this strategy.
    #
    #   require "etcetera"
    #
    #   app_strategy = Etcetera::AppStrategy::Unix.new(Etcetera::AppStrategy::AppStrategyArgs.new(
    #     top_level_domain: "org",
    #     author: "Acme Corp",
    #     app_name: "Frobnicator Plus"
    #   ))
    #
    #   home_dir = Etcetera.home_dir
    #
    #   app_strategy.home_dir == home_dir # => true
    #   app_strategy.config_dir.relative_path_from(home_dir) # => #<Pathname:.frobnicator-plus>
    #   app_strategy.data_dir.relative_path_from(home_dir) # => #<Pathname:.frobnicator-plus/data>
    #   app_strategy.cache_dir.relative_path_from(home_dir) # => #<Pathname:.frobnicator-plus/cache>
    #   app_strategy.state_dir.relative_path_from(home_dir) # => #<Pathname:.frobnicator-plus/state>
    #   app_strategy.runtime_dir.relative_path_from(home_dir) # => #<Pathname:.frobnicator-plus/runtime>
    class Unix < Data.define(
      # This is `.frobnicator-plus` in the above example.
      :home_dir,
      :unixy_name
    )
      include AppStrategy

      # Create a new Unix AppStrategy
      def self.new(args) = super(home_dir: Etcetera.home_dir, unixy_name: ".#{args.unixy_name}")

      private :unixy_name

      def config_dir = home_dir.join(unixy_name)

      def data_dir = home_dir.join(unixy_name).join("data/")

      def cache_dir = home_dir.join(unixy_name).join("cache/")

      def state_dir = home_dir.join(unixy_name).join("state/")

      def runtime_dir = home_dir.join(unixy_name).join("runtime/")
    end
  end
end
