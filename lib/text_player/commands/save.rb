# frozen_string_literal: true

require_relative "../command_result"

module TextPlayer
  module Commands
    # Command for saving game state
    Save = Data.define(:savefile) do
      def input
        "save"
      end

      def execute(game)
        # Note: we could check if the file exists and delete it here, but
        # instead we will let dfrotz handle it in case the save fails.
        game.write(input)
        game.read_until(TextPlayer::FILENAME_PROMPT_REGEX)
        game.write(savefile.filename)

        result = game.read_until(/Overwrite existing file\? |Ok\.|Failed\.|>/i)

        if result.include?("Overwrite existing file?")
          game.write("y")
          result += game.read_until(/Ok\.|Failed\.|>/i)
        end

        success = result.include?("Ok.")
        message = if success
          "[#{savefile.slot}] Game saved successfully"
        else
          "Save operation failed"
        end

        CommandResult.new(
          input: input,
          raw_output: result,
          operation: :save,
          success: success,
          message: message,
          slot: savefile.slot,
          filename: savefile.filename
        )
      end
    end
  end
end
