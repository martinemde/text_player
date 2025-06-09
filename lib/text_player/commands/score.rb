# frozen_string_literal: true

require_relative "../command_result"

module TextPlayer
  module Commands
    # Command for getting game score
    Score = Data.define do
      def input
        "score"
      end

      def execute(game)
        game.write(input)
        raw_output = game.read_until(TextPlayer::PROMPT_REGEX)

        score, out_of = nil
        if TextPlayer::SCORE_REGEX =~ raw_output
          score, out_of = $1, $2
        end

        # Some games give dialog instead of score
        # We will return what the game says as a success
        # whether or not we find a score.
        CommandResult.new(
          input:,
          raw_output:,
          operation: :score,
          success: true,
          score:,
          out_of:
        )
      end
    end
  end
end
