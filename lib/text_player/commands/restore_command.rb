# frozen_string_literal: true

require_relative "../command_result"

module TextPlayer
  module Commands
    # Command for restoring game state
    RestoreCommand = Data.define(:input, :slot, :game_filename) do
      def execute(process)
        unless process.running?
          return CommandResult.new(
            input: input,
            operation: :error,
            success: false,
            message: "Game not running"
          )
        end

        process.write("restore")
        process.read_until(TextPlayer::FILENAME_PROMPT_REGEX)
        process.write(save_filename)

        result = process.read_until(/Ok\.|Failed\.|not found|>/i)

        success = result.include?("Ok.")
        message = if success
          "Game restored successfully"
        elsif result.include?("Failed") || result.include?("not found")
          "Restore failed - file not found or corrupted"
        else
          "Restore operation completed"
        end

        CommandResult.new(
          input: input,
          raw_output: result,
          operation: :restore,
          success: success,
          message: message,
          slot: slot,
          filename: save_filename
        )
      end

      private

      def save_filename
        "saves/#{game_filename.delete_suffix(".z5")}_#{slot}.qzl"
      end
    end
  end
end
