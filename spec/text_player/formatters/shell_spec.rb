# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Formatters::Shell do
  let(:game_output) do
    " Library                                             Score: 30       Moves: 15\n\nLibrary\nYou are in a dusty library filled with ancient books.\nSunlight streams through tall windows.\n\n>"
  end

  def game_output_formatter(raw_output, input: "look")
    command_result = TextPlayer::CommandResult.from_game_output(input:, raw_output:)
    described_class.new(command_result)
  end

  def system_output_formatter(input: "command", **kwargs)
    command_result = TextPlayer::CommandResult.new(input:, **kwargs)
    described_class.new(command_result)
  end

  describe "#to_s" do
    context "with game commands" do
      it "returns raw output" do
        expect(game_output_formatter(game_output).to_s).to eq(game_output)
      end

      it "returns raw output of failed commands" do
        expect(game_output_formatter("You can't go that way.\n\n>").to_s).to eq("You can't go that way.\n\n>")
      end

      it "returns message if present instead of raw output" do
        command_result = TextPlayer::CommandResult.new(
          input: "look",
          raw_output: "original output",
          message: "custom message",
          operation: :game
        )
        formatter = described_class.new(command_result)
        expect(formatter.to_s).to eq("custom message")
      end
    end

    context "with system commands" do
      context "successful save" do
        it "formats system feedback with success indicator" do
          result = system_output_formatter(
            input: "save test.sav",
            operation: :save,
            success: true,
            message: "Game saved successfully",
            filename: "test.sav"
          ).to_s

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
          result = system_output_formatter(
            input: "restore missing.sav",
            operation: :restore,
            success: false,
            message: "File not found",
            filename: "missing.sav"
          ).to_s
          expect(result).to include("✗")
          expect(result).to include("RESTORE")
          expect(result).to include("File not found")
          expect(result).to include("\e[31m") # Red color
          expect(result).to include("\e[0m")  # Reset color
        end
      end

      context "quit command" do
        it "formats system feedback with success indicator" do
          result = system_output_formatter(
            input: "quit",
            operation: :quit,
            success: true,
            message: "Goodbye!"
          ).to_s
          expect(result).to include("✓")
          expect(result).to include("QUIT")
          expect(result).to include("Goodbye!")
        end
      end
    end

    context "with score command" do
      it "returns the raw output" do
        result = system_output_formatter(
          input: "score",
          operation: :score,
          success: true,
          raw_output: "Your score is 150 out of 300"
        ).to_s
        expect(result).to eq("Your score is 150 out of 300")
      end
    end
  end

  describe "#to_h" do
    it "includes base formatter data plus shell-specific fields" do
      hash = game_output_formatter(game_output).to_h

      expect(hash[:input]).to eq("look")
      expect(hash[:operation]).to eq(:game)
      expect(hash[:success]).to be true
      expect(hash[:raw_output]).to eq(game_output)
      expect(hash[:formatted_output]).to eq(game_output)
    end

    context "with failed command" do
      it "includes formatted output without color in to_h" do
        hash = game_output_formatter("I don't understand that.\n>").to_h
        expect(hash[:formatted_output]).to eq("I don't understand that.\n>")
      end
    end

    context "with system command" do
      it "includes base formatter data plus shell-specific fields" do
        hash = system_output_formatter(
          input: "save",
          operation: :save,
          success: true,
          message: "Saved",
          raw_output: "Saved"
        ).to_h

        expect(hash[:input]).to eq("save")
        expect(hash[:operation]).to eq(:save)
        expect(hash[:success]).to be true
        expect(hash[:raw_output]).to eq("Saved")
      end
    end
  end

  describe "#write" do
    context "with game command" do
      it "writes content and colored prompt separately" do
        stream = StringIO.new
        game_output_formatter("You can't do that.\n>").write(stream)

        output = stream.string
        expect(output).to include("You can't do that.\n")
        expect(output).to include("\e[31m>\e[0m") # Red prompt for failure
      end
    end

    context "with successful game command" do
      it "writes content and green prompt" do
        stream = StringIO.new
        game_output_formatter("You look around.\n>", input: "look").write(stream)

        output = stream.string
        expect(output).to include("You look around.\n")
        expect(output).to include("\e[32m>\e[0m") # Green prompt for success
      end
    end

    context "with failed game command with double newlines" do
      it "writes content and colored prompt" do
        stream = StringIO.new
        game_output_formatter("You can't do that.\n\n>").write(stream)

        output = stream.string
        expect(output).to include("You can't do that.\n\n")
        expect(output).to include("\e[31m>\e[0m") # Red prompt for failure
      end
    end

    context "with system command" do
      it "writes formatted system feedback" do
        stream = StringIO.new
        system_output_formatter(
          input: "save test",
          operation: :save,
          success: true,
          message: "Game saved"
        ).write(stream)

        output = stream.string
        expect(output).to include("✓")
        expect(output).to include("SAVE")
        expect(output).to include("Game saved")
      end
    end
  end
end
