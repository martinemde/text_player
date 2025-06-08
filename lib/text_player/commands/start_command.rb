# frozen_string_literal: true

require_relative "../command_result"

module TextPlayer
  module Commands
    # Command for starting the game
    # This is used to start the game and is not accessible by the user.
    StartCommand = Data.define do
      def input
        nil
      end

      def execute(game)
        raw_output = game.read_until(TextPlayer::PROMPT_REGEX)

        # Handle "Press any key" prompts - be more specific
        max_iterations = 5
        while /(Press|Hit|More)\s+/i.match?(raw_output)
          game.write(" ")
          raw_output += game.read_until(TextPlayer::PROMPT_REGEX)
          max_iterations -= 1
          break if max_iterations.zero?
        end

        # Skip introduction if offered
        if raw_output.include?("introduction")
          game.write("no")
          raw_output += game.read_until(TextPlayer::PROMPT_REGEX)
        end

        CommandResult.new(
          input: input,
          raw_output: raw_output,
          operation: :start,
          success: true,
          message: "Game started successfully"
        )
      end
    end
  end
end
