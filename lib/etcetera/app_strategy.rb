# frozen_string_literal: true

module Etcetera
  # These strategies require you to provide some information on your application, and they will in turn locate the configuration/data/cache directory specifically for your application.
  #
  # Allows applications to retrieve the paths of configuration, data, and cache directories specifically for them.
  module AppStrategy
    # The arguments to the creator method of an AppStrategy.
    #
    # +top_level_domain+:: The top level domain of the application, e.g. +com+, +org+, or <tt>io.github</tt>.
    # +author+:: The name of the author of the application.
    # +app_name+:: The application’s name. This should be capitalised if appropriate.
    class AppStrategyArgs < Data.define(:top_level_domain, :author, :app_name)
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

    ##
    # :method: home_dir
    # :call-seq:
    #   home_dir -> Pathname
    #
    # Gets the home directory of the current user.

    # @!method home_dir
    #   Gets the home directory of the current user.
    #   @return [Pathname]

    ##
    # :method: config_dir
    # :call-seq:
    #   config_dir -> Pathname
    #
    # Gets the configuration directory for your application.

    # @!method config_dir
    #   Gets the configuration directory for your application.
    #   @return [Pathname]

    ##
    # :method: data_dir
    # :call-seq:
    #   data_dir -> Pathname
    #
    # Gets the data directory for your application.

    # @!method data_dir
    #   Gets the data directory for your application.
    #   @return [Pathname]

    ##
    # :method: cache_dir
    # :call-seq:
    #   cache_dir -> Pathname
    #
    # Gets the cache directory for your application.

    # @!method cache_dir
    #   Gets the cache directory for your application.
    #   @return [Pathname]

    ##
    # :method: state_dir
    # :call-seq:
    #   state_dir -> Pathname or nil
    #
    # Gets the state directory for your application.
    # Currently, only the Xdg & Unix strategies support
    # this.

    # @!method state_dir
    #   Gets the state directory for your application.
    #   Currently, only the {Etcetera::AppStrategy::Xdg Xdg} & {Etcetera::AppStrategy::Unix Unix} strategies support
    #   this.
    #   @return [Pathname, nil]

    ##
    # :method: runtime_dir
    # :call-seq:
    #   runtime_dir -> Pathname or nil
    #
    # Gets the runtime directory for your application.
    # Currently, only the Xdg & Unix strategies support
    # this.
    #
    # Note: The {XDG Base Directory Specification}[https://specifications.freedesktop.org/basedir/latest/] places additional requirements on this
    # directory related to ownership, permissions, and persistence. This library does not check
    # these requirements.

    # @!method runtime_dir
    #   Gets the runtime directory for your application.
    #   Currently, only the {Etcetera::AppStrategy::Xdg Xdg} & {Etcetera::AppStrategy::Unix Unix} strategies support
    #   this.
    #
    #   Note: The {XDG Base Directory Specification}[https://specifications.freedesktop.org/basedir/latest/] places additional requirements on this
    #   directory related to ownership, permissions, and persistence. This library does not check
    #   these requirements.
    #   @return [Pathname, nil]

    # Constructs a path inside your application’s configuration directory to which a path of your choice has been appended.
    def in_config_dir(path) = config_dir.join(path)

    # Constructs a path inside your application’s data directory to which a path of your choice has been appended.
    def in_data_dir(path) = data_dir.join(path)

    # Constructs a path inside your application’s cache directory to which a path of your choice has been appended.
    def in_cache_dir(path) = cache_dir.join(path)

    # Constructs a path inside your application’s state directory to which a path of your choice has been appended.
    #
    # Currently, this is only implemented for the Xdg strategy.
    def in_state_dir(path) = state_dir&.join(path)

    # Constructs a path inside your application’s runtime directory to which a path of your choice has been appended.
    # Currently, only the Xdg & Unix strategies support
    # this.
    #
    # See the note in #runtime_dir for more information.
    def in_runtime_dir(path) = runtime_dir&.join(path)

    # Returns the current OS’s native AppStrategy.
    # This uses the Windows strategy on \Windows, Apple on macOS & iOS, and Xdg everywhere else.
    # This is the convention used by most GUI applications.
    def self.choose_native_strategy(args)
      if Gem.win_platform? then Windows.new(args)
      elsif RUBY_PLATFORM.include?("darwin") then Apple.new(args)
      else Xdg.new(args)
      end
    end

    # Returns the current OS’s default AppStrategy.
    # This uses the Windows strategy on \Windows, and Xdg everywhere else.
    # This is the convention used by most CLI applications.
    def self.choose_app_strategy(args)
      Gem.win_platform? ? Windows.new(args) : Xdg.new(args)
    end
  end
end
