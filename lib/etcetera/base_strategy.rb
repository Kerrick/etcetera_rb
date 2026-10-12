# frozen_string_literal: true

module Etcetera
  # These strategies simply provide the user’s configuration, data, and cache directories, without knowing about the application specifically.
  #
  # Provides configuration, data, and cache directories of the current user.
  module BaseStrategy
    # Returns the current OS’s native {BaseStrategy}[rdoc-ref:Etcetera::BaseStrategy].
    # This uses the {Windows}[rdoc-ref:Etcetera::BaseStrategy::Windows] strategy on Windows, {Apple}[rdoc-ref:Etcetera::BaseStrategy::Apple] on macOS & iOS, and {Xdg}[rdoc-ref:Etcetera::BaseStrategy::Xdg] everywhere else.
    # This is the convention used by most GUI applications.
    def self.choose_native_strategy
      if Gem.win_platform? then Windows.new
      elsif RUBY_PLATFORM.include?("darwin") then Apple.new
      else Xdg.new
      end
    end

    # Returns the current OS’s default {BaseStrategy}[rdoc-ref:Etcetera::BaseStrategy].
    # This uses the {Windows}[rdoc-ref:Etcetera::BaseStrategy::Windows] strategy on Windows, and {Xdg}[rdoc-ref:Etcetera::BaseStrategy::Xdg] everywhere else.
    # This is the convention used by most CLI applications.
    def self.choose_base_strategy
      Gem.win_platform? ? Windows.new : Xdg.new
    end
  end
end
