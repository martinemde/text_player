# frozen_string_literal: true

require "json"
require_relative "data"

module TextPlayer
  module Formatters
    # JSON formatter - returns JSON string of structured data
    class Json < Data
      def to_s
        JSON.generate(to_h)
      end
    end
  end
end
