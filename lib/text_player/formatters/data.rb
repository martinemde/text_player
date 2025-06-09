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
          status_data, remaining_after_status = TextPlayer::OutputParser.parse_status_line(raw_output)

          # Extract prompt from the remaining text
          prompt = extract_prompt(remaining_after_status)

          # Remove prompt from remaining text if found
          cleaned = remaining_after_status.dup
          if prompt
            lines = cleaned.split("\n")
            if lines.last&.strip == prompt
              lines.pop
              cleaned = lines.join("\n")
            end
          end

          # Final cleanup of remaining text
          output = final_cleanup(cleaned)

          {
            location: status_data[:location],
            score: status_data[:score],
            moves: status_data[:moves],
            time: status_data[:time],
            prompt: prompt,
            output: output,
            has_prompt: !prompt.nil?
          }
        end
      end



      def extract_prompt(text)
        # Extract prompt from end of text (usually ">")
        lines = text.split("\n")
        last_line = lines.last&.strip
        last_line if last_line&.match?(TextPlayer::PROMPT_REGEX)
      end



      def final_cleanup(text)
        # Clean up excessive whitespace but preserve paragraph structure
        # Remove more than 2 consecutive newlines (preserve paragraph breaks)
        text.gsub!(/\n{3,}/, "\n\n")
        # Remove lines that are only whitespace
        text.gsub!(/^\s+$/m, "")
        # Clean up any trailing/leading whitespace on lines
        text.gsub!(/[ \t]+$/, "")

        text.strip
      end


    end
  end
end
