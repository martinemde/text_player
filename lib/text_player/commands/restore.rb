# frozen_string_literal: true

require_relative "../command_result"

module TextPlayer
  module Commands
    # Command for restoring game state
    Restore = Data.define(:savefile) do
      def input
        "restore"
      end

      def execute(game)
        unless savefile.exist?
          return CommandResult.new(
            input: input,
            operation: :restore,
            success: false,
            message: "Restore failed - file not found",
            slot: savefile.slot,
            filename: savefile.filename
          )
        end

        game.write(input)
        game.read_until(TextPlayer::FILENAME_PROMPT_REGEX)
        game.write(savefile.filename)

        result = game.read_until(/Ok\.|Failed\.|not found|>/i)

        success = result.include?("Ok.")
        message = if success
          "Game restored successfully"
        elsif result.include?("Failed") || result.include?("not found")
          "Restore failed - file not found by dfrotz process even though it existed before running this command"
        else
          "Restore operation completed"
        end

        CommandResult.new(
          input: input,
          raw_output: result,
          operation: :restore,
          success: success,
          message: message,
          slot: savefile.slot,
          filename: savefile.filename
        )
      end
    end
  end
end
