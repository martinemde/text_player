# frozen_string_literal: true

module TextPlayer
  module Formatter
    # Shell formatter - interactive presentation with prompts and colors
    module Shell
      extend self

      def format(command_result)
        if command_result.action?
          content = display_content(command_result)

          # Look for prompt at the end (> or similar)
          # Match: content + optional newlines + > + optional spaces
          if TextPlayer::PROMPT_REGEX.match?(content)
            content = content.gsub(TextPlayer::PROMPT_REGEX, "").rstrip
            color = command_result.success? ? "\e[32m" : "\e[31m"
            "#{content}\n\n#{color}>\e[0m "
          else
            content
          end
        else
          format_system_feedback(command_result)
        end
      end

      private

      def format_system_feedback(command_result)
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

      def display_content(command_result)
        command_result.message || command_result.raw_output
      end
    end
  end
end
