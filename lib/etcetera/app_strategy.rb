# frozen_string_literal: true

module Etcetera
  # These strategies require you to provide some information on your application, and they will in turn locate the configuration/data/cache directory specifically for your application.
  #
  # Allows applications to retrieve the paths of configuration, data, and cache directories specifically for them.
  module AppStrategy
    # The arguments to the creator method of an {AppStrategy}[rdoc-ref:Etcetera::AppStrategy].
    #
    # +top_level_domain+:: The top level domain of the application, e.g. +com+, +org+, or <tt>io.github</tt>.
    # +author+:: The name of the author of the application.
    # +app_name+:: The application’s name. This should be capitalised if appropriate.
    AppStrategyArgs = Data.define(:top_level_domain, :author, :app_name) do
      def initialize(top_level_domain: "", author: "", app_name: "") = super

      # Constructs a bunde identifier from an +AppStrategyArgs+.
      #
      #   require "etcetera"
      #
      #   strategy_args = Etcetera::AppStrategy::AppStrategyArgs.new(
      #     top_level_domain: "org",
      #     author: "Acme Corp",
      #     app_name: "Frobnicator Plus"
      #   )
      #
      #   strategy_args.bundle_id # => "org.acme-corp.Frobnicator-Plus"
      def bundle_id
        author = self.author.downcase.tr(" ", "-")
        app_name = self.app_name.tr(" ", "-")
        [top_level_domain, author, app_name].reject(&:empty?).join(".")
      end

      # Returns a ‘unixy’ version of the application’s name, akin to what would usually be used as a binary name.
      #
      #   require "etcetera"
      #
      #   strategy_args = Etcetera::AppStrategy::AppStrategyArgs.new(
      #     top_level_domain: "org",
      #     author: "Acme Corp",
      #     app_name: "Frobnicator Plus"
      #   )
      #
      #   strategy_args.unixy_name # => "frobnicator-plus"
      def unixy_name = app_name.downcase.tr(" ", "-")
    end

    # Constructs a path inside your application’s configuration directory to which a path of your choice has been appended.
    def in_config_dir(path) = config_dir.join(path)

    # Constructs a path inside your application’s data directory to which a path of your choice has been appended.
    def in_data_dir(path) = data_dir.join(path)

    # Constructs a path inside your application’s cache directory to which a path of your choice has been appended.
    def in_cache_dir(path) = cache_dir.join(path)

    # Constructs a path inside your application’s state directory to which a path of your choice has been appended.
    #
    # Currently, this is only implemented for the {Xdg}[rdoc-ref:Etcetera::AppStrategy::Xdg] strategy.
    def in_state_dir(path) = state_dir&.join(path)

    # Constructs a path inside your application’s runtime directory to which a path of your choice has been appended.
    # Currently, only the {Xdg}[rdoc-ref:Etcetera::AppStrategy::Xdg] & {Unix}[rdoc-ref:Etcetera::AppStrategy::Unix] strategies support
    # this.
    #
    # See the note in +runtime_dir+ for more information.
    def in_runtime_dir(path) = runtime_dir&.join(path)

    # Returns the current OS’s native {AppStrategy}[rdoc-ref:Etcetera::AppStrategy].
    # This uses the {Windows}[rdoc-ref:Etcetera::AppStrategy::Windows] strategy on Windows, {Apple}[rdoc-ref:Etcetera::AppStrategy::Apple] on macOS & iOS, and {Xdg}[rdoc-ref:Etcetera::AppStrategy::Xdg] everywhere else.
    # This is the convention used by most GUI applications.
    def self.choose_native_strategy(args)
      if Gem.win_platform? then Windows.new(args)
      elsif RUBY_PLATFORM.include?("darwin") then Apple.new(args)
      else Xdg.new(args)
      end
    end

    # Returns the current OS’s default {AppStrategy}[rdoc-ref:Etcetera::AppStrategy].
    # This uses the {Windows}[rdoc-ref:Etcetera::AppStrategy::Windows] strategy on Windows, and {Xdg}[rdoc-ref:Etcetera::AppStrategy::Xdg] everywhere else.
    # This is the convention used by most CLI applications.
    def self.choose_app_strategy(args)
      Gem.win_platform? ? Windows.new(args) : Xdg.new(args)
    end
  end
end
