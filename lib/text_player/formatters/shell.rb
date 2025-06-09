# frozen_string_literal: true

require_relative "base"

module TextPlayer
  module Formatters
    # Shell formatter - interactive presentation with prompts and colors
    class Shell < Base
      def to_s
        if command_result.action_command?
          format_game_output
        else
          format_system_feedback
        end
      end

      def to_h
        super.merge(
          formatted_output: to_s
        )
      end

      def write(stream)
        if command_result.action_command?
          content, prompt = extract_prompt(display_content)
          stream.write(content)
          if prompt
            color = command_result.success? ? "\e[32m" : "\e[31m"
            stream.write("#{color}#{prompt}\e[0m")
          end
        else
          stream.write(to_s)
        end
      end

      private

      def format_system_feedback
        return command_result.raw_output if %i[start score].include?(command_result.operation)

        prefix = command_result.success? ? "\e[32m✓\e[0m" : "\e[31m✗\e[0m"
        feedback = "#{prefix} #{command_result.operation.upcase}: #{command_result.message}"

        # Add details if present
        if command_result.details.any?
          detail_lines = command_result.details.map { |k, v| "  #{k}: #{v}" }
          feedback += "\n#{detail_lines.join("\n")}"
        end

        feedback
      end

      def format_game_output
        display_content
      end

      def display_content
        command_result.message || command_result.raw_output
      end

      def extract_prompt(content)
        # Look for prompt at the end (> or similar)
        # Match: content + optional newlines + > + optional spaces
        if TextPlayer::PROMPT_REGEX.match?(content)
          content = content.gsub(TextPlayer::PROMPT_REGEX, "").rstrip
          [content + "\n\n", "> "]
        else
          [content, nil]
        end
      end
    end
  end
end
