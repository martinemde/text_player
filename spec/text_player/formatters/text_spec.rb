# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Formatter::Text do
  let(:game_output) { "You are in a dark room.\n>" }
  let(:command_result) do
    TextPlayer::CommandResult.new(
      operation: :action,
      success: true,
      input: "look",
      raw_output: game_output
    )
  end

  describe "#format" do
    it "returns raw output with prompt removed and double newlines" do
      expect(described_class.format(command_result)).to eq("You are in a dark room.\n\n")
    end

    it "returns message if present instead of raw output" do
      command_result_with_message = TextPlayer::CommandResult.new(
        operation: :action,
        success: true,
        input: "look",
        raw_output: "original output",
        message: "custom message"
      )
      expect(described_class.format(command_result_with_message)).to eq("custom message\n\n")
    end

    context "with complex output" do
      let(:complex_output) do
        " Forest Path                                        Score: 25       Moves: 10\n\nForest Path\nYou are on a winding forest path. Tall trees tower above you,\ntheir leaves rustling in the gentle breeze.\n\n>"
      end

      let(:command_result) do
        TextPlayer::CommandResult.new(
          operation: :action,
          success: true,
          input: "look",
          raw_output: complex_output
        )
      end

      it "returns output with prompt removed and double newlines" do
        expected = " Forest Path                                        Score: 25       Moves: 10\n\nForest Path\nYou are on a winding forest path. Tall trees tower above you,\ntheir leaves rustling in the gentle breeze."
        expect(described_class.format(command_result)).to eq("#{expected}\n\n")
      end
    end

    context "with system command" do
      let(:system_result) do
        TextPlayer::CommandResult.new(
          input: "save game",
          operation: :save,
          success: true,
          message: "Game saved successfully",
          raw_output: ""
        )
      end

      it "returns message with double newlines" do
        expect(described_class.format(system_result)).to eq("Game saved successfully\n\n")
      end
    end

    context "with no message and empty raw output" do
      let(:empty_result) do
        TextPlayer::CommandResult.new(
          input: "test",
          raw_output: ""
        )
      end

      it "returns double newlines for empty content" do
        expect(described_class.format(empty_result)).to eq("\n\n")
      end
    end
  end
end
