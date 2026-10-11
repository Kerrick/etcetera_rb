# frozen_string_literal: true

require "pathname"

module Etcetera
  # These strategies require you to provide some information on your
  # application, and they will in turn locate the configuration/data/cache
  # directory specifically for your application.
  #
  # Allows applications to retrieve the paths of configuration, data, and cache
  # directories specifically for them.
  #
  # Every strategy implements this interface: include it in your own class and
  # implement the six methods that raise NotImplementedError. The five
  # <tt>in_*</tt> methods come for free.
  module AppStrategy
    # The arguments to the creator method of an AppStrategy.
    AppStrategyArgs = Data.define(:top_level_domain, :author, :app_name) do
      # Constructs a bundle identifier from an AppStrategyArgs.
      #
      #   args = Etcetera::AppStrategy::AppStrategyArgs.new(
      #     top_level_domain: "org",
      #     author: "Acme Corp",
      #     app_name: "Frobnicator Plus"
      #   )
      #
      #   args.bundle_id # => "org.acme-corp.Frobnicator-Plus"
      def bundle_id
        [top_level_domain, author.downcase.tr(" ", "-"), app_name.tr(" ", "-")]
          .reject(&:empty?)
          .join(".")
      end

      # Returns a 'unixy' version of the application's name, akin to what would
      # usually be used as a binary name.
      #
      #   args = Etcetera::AppStrategy::AppStrategyArgs.new(
      #     top_level_domain: "org",
      #     author: "Acme Corp",
      #     app_name: "Frobnicator Plus"
      #   )
      #
      #   args.unixy_name # => "frobnicator-plus"
      def unixy_name
        app_name.downcase.tr(" ", "-")
      end
    end

    # Returns the current OS's native Etcetera::AppStrategy.
    #
    # This uses the Windows strategy on Windows, Apple on macOS & iOS, and Xdg
    # everywhere else. This is the convention used by most GUI applications.
    def self.choose_native_strategy(args)
      native_strategy_class.new(args)
    end

    # Returns the current OS's default Etcetera::AppStrategy.
    #
    # This uses the Windows strategy on Windows, and Xdg everywhere else. This
    # is the convention used by most CLI applications.
    def self.choose_app_strategy(args)
      base_strategy_class.new(args)
    end

    # Gets the home directory of the current user.
    def home_dir
      raise NotImplementedError, "#{self.class} must implement #home_dir"
    end

    # Gets the configuration directory for your application.
    def config_dir
      raise NotImplementedError, "#{self.class} must implement #config_dir"
    end

    # Gets the data directory for your application.
    def data_dir
      raise NotImplementedError, "#{self.class} must implement #data_dir"
    end

    # Gets the cache directory for your application.
    def cache_dir
      raise NotImplementedError, "#{self.class} must implement #cache_dir"
    end

    # Gets the state directory for your application.
    # Currently, only the Xdg & Unix strategies support this.
    def state_dir
      raise NotImplementedError, "#{self.class} must implement #state_dir"
    end

    # Gets the runtime directory for your application.
    # Currently, only the Xdg & Unix strategies support this.
    #
    # Note: The XDG Base Directory Specification
    # (https://specifications.freedesktop.org/basedir/latest/) places additional
    # requirements on this directory related to ownership, permissions, and
    # persistence. This library does not check these requirements.
    def runtime_dir
      raise NotImplementedError, "#{self.class} must implement #runtime_dir"
    end

    # Constructs a path inside your application's configuration directory to
    # which a path of your choice has been appended.
    def in_config_dir(path)
      config_dir.join(path)
    end

    # Constructs a path inside your application's data directory to which a path
    # of your choice has been appended.
    def in_data_dir(path)
      data_dir.join(path)
    end

    # Constructs a path inside your application's cache directory to which a
    # path of your choice has been appended.
    def in_cache_dir(path)
      cache_dir.join(path)
    end

    # Constructs a path inside your application's state directory to which a
    # path of your choice has been appended.
    #
    # Currently, this is only implemented for the Xdg strategy.
    def in_state_dir(path)
      state_dir&.join(path)
    end

    # Constructs a path inside your application's runtime directory to which a
    # path of your choice has been appended.
    # Currently, only the Xdg & Unix strategies support this.
    #
    # See the note in #runtime_dir for more information.
    def in_runtime_dir(path)
      runtime_dir&.join(path)
    end

    def self.native_strategy_class
      if RUBY_PLATFORM.match?(/darwin/)
        Apple
      elsif WINDOWS_HOST
        Windows
      else
        Xdg
      end
    end

    def self.base_strategy_class
      WINDOWS_HOST ? Windows : Xdg
    end

    private_class_method :native_strategy_class, :base_strategy_class
  end
end
