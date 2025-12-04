# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Formatter::Shell do
  let(:game_output) do
    " Library                                             Score: 30       Moves: 15\n\nLibrary\nYou are in a dusty library filled with ancient books.\nSunlight streams through tall windows.\n\n>"
  end

  def game_command_result(raw_output, input: "look", success: true)
    TextPlayer::CommandResult.new(
      operation: :action,
      success:,
      input:,
      raw_output:
    )
  end

  def system_command_result(input: "command", **kwargs)
    TextPlayer::CommandResult.new(
      operation: :system,
      success: true,
      input:,
      **kwargs
    )
  end

  describe "#format" do
    context "with game commands" do
      it "returns formatted output with colored prompt" do
        result = game_command_result(game_output)
        output = described_class.format(result)
        expect(output).to include("Library")
        expect(output).to include("dusty library")
        expect(output).to include("\e[32m>\e[0m") # Green prompt for success
      end

      it "returns formatted output with colored prompt for failed commands" do
        result = game_command_result("You can't go that way.\n\n>")
        output = described_class.format(result)
        expect(output).to include("You can't go that way.")
        expect(output).to include("\e[32m>\e[0m") # Green prompt (success is still true)
      end

      it "returns message if present instead of raw output" do
        command_result = TextPlayer::CommandResult.new(
          operation: :action,
          success: true,
          input: "look",
          raw_output: "original output",
          message: "custom message"
        )
        expect(described_class.format(command_result)).to eq("custom message")
      end
    end

    context "with system commands" do
      context "successful save" do
        it "formats system feedback with success indicator" do
          command_result = system_command_result(
            input: "save test.sav",
            operation: :save,
            success: true,
            message: "Game saved successfully",
            filename: "test.sav"
          )
          result = described_class.format(command_result)

          expect(result).to include("✓")
          expect(result).to include("SAVE")
          expect(result).to include("Game saved successfully")
          expect(result).to include("\e[32m") # Green color
          expect(result).to include("\e[0m")  # Reset color
          expect(result).to include("filename: test.sav")
        end
      end

      context "failed restore" do
        it "formats system feedback with failure indicator" do
          command_result = system_command_result(
            input: "restore missing.sav",
            operation: :restore,
            success: false,
            message: "File not found",
            filename: "missing.sav"
          )
          result = described_class.format(command_result)
          expect(result).to include("✗")
          expect(result).to include("RESTORE")
          expect(result).to include("File not found")
          expect(result).to include("\e[31m") # Red color
          expect(result).to include("\e[0m")  # Reset color
        end
      end

      context "quit command" do
        it "formats system feedback with success indicator" do
          command_result = system_command_result(
            input: "quit",
            operation: :quit,
            success: true,
            message: "Goodbye!"
          )
          result = described_class.format(command_result)
          expect(result).to include("✓")
          expect(result).to include("QUIT")
          expect(result).to include("Goodbye!")
        end
      end
    end

    context "with score command" do
      it "returns the raw output" do
        command_result = system_command_result(
          input: "score",
          operation: :score,
          success: true,
          raw_output: "Your score is 150 out of 300"
        )
        result = described_class.format(command_result)
        expect(result).to eq("Your score is 150 out of 300")
      end
    end
  end
end
