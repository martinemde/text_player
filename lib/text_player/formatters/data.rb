# frozen_string_literal: true

require_relative "base"
require_relative "../output_parser"

module TextPlayer
  module Formatters
    # Data formatter - parses game-specific data and returns structured output
    class Data < Base
      def to_h
        super.merge(parsed_data)
      end

      private

      def parsed_data
        @parsed_data ||= begin
          raw_output = command_result.raw_output

          # Use OutputParser to extract status line data
          status_data, remaining = TextPlayer::OutputParser.parse_status_line(raw_output)

          # Extract prompt from the remaining text
          prompt_data, remaining = TextPlayer::OutputParser.extract_prompt(remaining)

          # Final cleanup of remaining text
          output = TextPlayer::OutputParser.cleanup(remaining)

          # Merge all extracted data
          status_data.merge(prompt_data, output: output)
        end
      end
    end
  end
end
