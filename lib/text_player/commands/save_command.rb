# frozen_string_literal: true

require_relative "../command_result"

module TextPlayer
  module Commands
    # Command for saving game state
    SaveCommand = Data.define(:input, :slot, :game_filename) do
      def execute(process)
        unless process.running?
          return CommandResult.new(
            input: input,
            operation: :error,
            success: false,
            message: "Game not running"
          )
        end

        process.write("save")
        process.read_until(TextPlayer::FILENAME_PROMPT_REGEX)
        process.write(save_filename)

        result = process.read_until(/Overwrite existing file\? |Ok\.|Failed\.|>/i)

        if result.include?("Overwrite existing file?")
          process.write("y")
          result += process.read_until(/Ok\.|Failed\.|>/i)
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
