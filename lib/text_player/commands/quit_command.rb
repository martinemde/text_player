# frozen_string_literal: true

require_relative "../command_result"

module TextPlayer
  module Commands
    # Command for quitting the game
    QuitCommand = Data.define do
      def input
        "quit"
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

        begin
          process.write(input)
          # Give the game a moment to process quit and ask for confirmation
          sleep(0.2)
          # Send 'y' to confirm quit
          process.write("y")
        rescue Errno::EPIPE
          # Expected when process exits - ignore
        end

        process.terminate

        CommandResult.new(
          input: input,
          operation: :quit,
          success: true,
          message: "Game quit successfully"
        )
      end
    end
  end
end
