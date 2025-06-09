# frozen_string_literal: true

require_relative "formatters/base"
require_relative "formatters/text"
require_relative "formatters/data"
require_relative "formatters/json"
require_relative "formatters/shell"

module TextPlayer
  # UI Formatters - Stream-based output handling for different interfaces
  module Formatters
    def self.by_name(name)
      case name
      when :data then Data
      when :json then Json
      when :shell then Shell
      else Text
      end
    end

    def self.create(name, command_result)
      by_name(name).new(command_result)
    end
  end
end
