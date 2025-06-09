# frozen_string_literal: true

require_relative "base"

module TextPlayer
  module Formatters
    # Plain text formatter - returns raw output
    class Text < Base
      def to_s
        content = command_result.message || command_result.raw_output
        content = remove_prompt(content)
        "#{content}\n\n"
      end

      private

      def remove_prompt(content)
        # Remove prompt at the end (> or similar)
        content.gsub(/\n*>\s*$/, "")
      end
    end
  end
end
