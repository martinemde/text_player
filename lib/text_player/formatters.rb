# frozen_string_literal: true

require_relative "formatters/base"
require_relative "formatters/text"
require_relative "formatters/data"
require_relative "formatters/json"
require_relative "formatters/shell"

module TextPlayer
  # UI Formatters - Stream-based output handling for different interfaces
  module Formatters
    def self.create(type, command_result)
      case type
      when :data then Data.new(command_result)
      when :json then Json.new(command_result)
      when :shell then Shell.new(command_result)
      else
        Text.new(command_result)
      end
    end
  end
end
