# frozen_string_literal: true

require_relative "../command_result"

module TextPlayer
  module Commands
    # Command for saving game state
    SaveCommand = Data.define(:save) do
      def input
        "save"
      end

      def execute(game)
        game.write(input)
        game.read_until(TextPlayer::FILENAME_PROMPT_REGEX)
        game.write(save.filename)

        result = game.read_until(/Overwrite existing file\? |Ok\.|Failed\.|>/i)

        if result.include?("Overwrite existing file?")
          game.write("y")
          result += game.read_until(/Ok\.|Failed\.|>/i)
        end

        success = result.include?("Ok.")
        message = if success
          "Game saved successfully"
        elsif result.include?("Failed.")
          "Save operation failed"
        else
          "Save completed"
        end

        CommandResult.new(
          input: input,
          raw_output: result,
          operation: :save,
          success: success,
          message: message,
          slot: save.slot,
          filename: save.filename
        )
      end
    end
  end
end
