# frozen_string_literal: true

require_relative "../command_result"

module TextPlayer
  module Commands
    # Command for getting game score
    ScoreCommand = Data.define do
      def input
        "score"
      end

      def execute(process)
        unless process.running?
          return CommandResult.new(
            input:,
            operation: :error,
            success: false,
            message: "Game not running"
          )
        end

        process.write(input)
        raw_output = process.read_until(TextPlayer::PROMPT_REGEX)

        CommandResult.new(
          input:,
          raw_output:,
          operation: :score,
          success: true
        )
      end
    end
  end
end
