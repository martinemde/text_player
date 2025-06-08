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

      def execute(process)
        raw_output = process.read_until(PROMPT_REGEX)

        # Handle "Press any key" prompts - be more specific
        while /(Press|Hit|More)\s+/i.match?(raw_output)
          process.write(" ")
          raw_output += process.read_until(PROMPT_REGEX)
        end

        # Skip introduction if offered
        if raw_output.include?("introduction")
          process.write("no")
          raw_output += process.read_until(PROMPT_REGEX)
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
