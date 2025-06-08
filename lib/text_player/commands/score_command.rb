# frozen_string_literal: true

require_relative "../command_result"

module TextPlayer
  module Commands
    # Command for getting game score
    ScoreCommand = Data.define do
      def input
        "score"
      end

      def execute(game)
        game.write(input)
        raw_output = game.read_until(TextPlayer::PROMPT_REGEX)

        if TextPlayer::SCORE_REGEX =~ raw_output
          score, out_of = $1, $2
          CommandResult.new(
            input:,
            raw_output:,
            operation: :score,
            success: true,
            message: "Score: #{score}/#{out_of}",
            score:,
            out_of:
          )
        else
          CommandResult.new(
            input:,
            raw_output:,
            operation: :score,
            success: false,
            message: "Score not found in output",
            score: nil,
            out_of: nil
          )
        end
      end
    end
  end
end
