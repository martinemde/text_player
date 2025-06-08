# frozen_string_literal: true

require_relative "../command_result"

module TextPlayer
  module Commands
    # Command for generic game actions (look, go north, take sword, etc.)
    ActionCommand = Data.define(:input) do
      def execute(process)
        unless process.running?
          return CommandResult.new(
            input: input,
            operation: :error,
            success: false,
            message: "Game not running"
          )
        end

        process.write(input)
        raw_output = process.read_all

        CommandResult.new(
          input: input,
          raw_output: raw_output,
          operation: :game,
          success: true
        )
      end
    end
  end
end
