# frozen_string_literal: true

require "json"
require_relative "command_result"

module TextPlayer
  # UI Formatters - Abstract output handling for different interfaces
  module Formatters
    def self.create(type)
      case type
      when :data then DataFormatter.new
      when :json then JsonFormatter.new
      when :shell then ShellFormatter.new
      else
        TextFormatter.new
      end
    end

    # Base formatter with common parsing logic and feedback handling
    class BaseFormatter
      SCORE_PATTERN = /Score:\s*(\d+)/i
      MOVES_PATTERN = /Moves:\s*(\d+)/i
      PROMPT_PATTERN = /^>\s*$/

      # Format CommandResult objects
      def format(command_result)
        raise NotImplementedError, "Subclasses must implement format method"
      end

      protected
      def has_prompt?(text)
        text.match?(PROMPT_PATTERN)
      end

      private

      def valid_location?(location)
        location.length.positive? &&
          !location.start_with?("I don't ") &&
          !location.start_with?("I can't ") &&
          !location.start_with?("What do you ") &&
          !location.start_with?("You're ") &&
          !location.start_with?("You ")
      end
    end

    class TextFormatter < BaseFormatter
      def format(command_result)
        command_result.raw_output
      end
    end

    # Data formatter - returns structured hash
    class DataFormatter < BaseFormatter
      def format(command_result)
        raw_output = command_result.raw_output
        location, remaining_text = extract_location(raw_output)

        {
          type: "game_output",
          location: location,
          score: extract_score(raw_output),
          moves: extract_moves(raw_output),
          output: clean_game_text(remaining_text),
          has_prompt: has_prompt?(raw_output)
        }
      end

      private

      def extract_location(lines, data)
        first_line = lines.first&.strip

        if first_line.include?("   ") # remove any extra info that is right aligned.
          location = first_line.split(/   /, 2).first.strip
          extract_score(lines, data)
          extract_moves(lines, data)
        else
          location = first_line
        end

        data[:location] = location if valid_location?(location)

        lines.drop(1)
      end

      def extract_score(text)
        match = text.match(SCORE_PATTERN)
        match ? match[1].to_i : nil
      end

      def extract_moves(text)
        match = text.match(MOVES_PATTERN)
        match ? match[1].to_i : nil
      end



      def clean_game_text(text)
        # Remove score/moves lines and prompt, keep game narrative
        cleaned = text.dup
        cleaned.gsub!(SCORE_PATTERN, "")
        cleaned.gsub!(MOVES_PATTERN, "")
        cleaned.gsub!(/^>\s*$/, "")
        cleaned.squeeze!("\n")
        cleaned.strip
      end
    end

    # JSON formatter - returns JSON string of structured data
    class JsonFormatter < DataFormatter
      def format(command_result)
        JSON.generate(super)
      end
    end

    # Shell formatter - returns full output ready for interactive shell
    class ShellFormatter < BaseFormatter
      def format(command_result)
        case command_result.operation
        when :score
          command_result.message
        when :save, :restore, :quit
          format_feedback(
            operation: command_result.operation,
            success: command_result.success,
            message: command_result.message,
            **command_result.details
          )
        else
          command_result.raw_output
        end
      end

      def format_feedback(operation:, success:, message:, **details)
        # Format feedback for shell display with color coding
        status_indicator = success ? "✓" : "✗"
        color = success ? "\e[32m" : "\e[31m" # Green for success, red for failure
        reset = "\e[0m"

        feedback = "#{color}#{status_indicator} #{operation.upcase}: #{message}#{reset}"

        # Add details if present
        if details.any?
          detail_lines = details.map { |k, v| "  #{k}: #{v}" }
          feedback += "\n#{detail_lines.join("\n")}"
        end

        feedback += "\n>"
        feedback
      end

      def prompt_for_command(prompt_text = "Enter command: ")
        print prompt_text
        gets&.strip
      end
    end
  end
end
