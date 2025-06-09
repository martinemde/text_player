# frozen_string_literal: true

require_relative "../command_result"

module TextPlayer
  module Commands
    # Command for generic game actions (look, go north, take sword, etc.)
    Action = Data.define(:input) do
      def execute(game)
        game.write(input)
        raw_output = game.read_until(TextPlayer::PROMPT_REGEX)

        CommandResult.from_game_output(
          input: input,
          raw_output: raw_output,
          operation: :action,
          success: !failure_detected?(raw_output)
        )
      end

      def failure_detected?(output)
        TextPlayer::FAILURE_PATTERNS.any? { |pattern| output.match?(pattern) }
      end
    end
  end
end
