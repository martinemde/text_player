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
        content.gsub(TextPlayer::PROMPT_REGEX, "").rstrip
      end
    end
  end
end
