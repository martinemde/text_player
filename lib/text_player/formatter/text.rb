# frozen_string_literal: true

module TextPlayer
  module Formatter
    # Plain text formatter - returns raw output
    module Text
      extend self

      def format(command_result)
        content = command_result.message || command_result.raw_output
        content = content.gsub(TextPlayer::PROMPT_REGEX, "").rstrip
        "#{content}\n\n"
      end
    end
  end
end
