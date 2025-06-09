# frozen_string_literal: true

require_relative "../command_result"

module TextPlayer
  module Commands
    # Command for quitting the game
    Quit = Data.define do
      def input
        "quit"
      end

      def execute(game)
        begin
          game.write(input)
          sleep(0.2)
          game.write("y")
        rescue Errno::EPIPE
          # Expected when process exits - ignore
        ensure
          game.terminate
        end

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
