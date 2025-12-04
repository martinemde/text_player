# frozen_string_literal: true

require_relative "formatter/text"
require_relative "formatter/json"
require_relative "formatter/shell"

module TextPlayer
  # UI Formatter - Stream-based output handling for different interfaces
  module Formatter
    def self.by_name(name)
      case name
      when :json then Json
      when :shell then Shell
      else Text
      end
    end
  end
end
