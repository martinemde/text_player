# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Formatters::Text do
  let(:game_output) { "You are in a dark room.\n>" }
  let(:command_result) do
    TextPlayer::CommandResult.from_game_output(
      input: "look",
      raw_output: game_output
    )
  end

  let(:formatter) { described_class.new(command_result) }

  describe "#to_s" do
    it "returns raw output with prompt removed and double newlines" do
      expect(formatter.to_s).to eq("You are in a dark room.\n\n")
    end

    it "returns message if present instead of raw output" do
      command_result_with_message = TextPlayer::CommandResult.new(
        input: "look",
        raw_output: "original output",
        message: "custom message",
        operation: :game
      )
      formatter_with_message = described_class.new(command_result_with_message)
      expect(formatter_with_message.to_s).to eq("custom message\n\n")
    end

    context "with complex output" do
      let(:complex_output) do
        " Forest Path                                        Score: 25       Moves: 10\n\nForest Path\nYou are on a winding forest path. Tall trees tower above you,\ntheir leaves rustling in the gentle breeze.\n\n>"
      end

      let(:command_result) do
        TextPlayer::CommandResult.from_game_output(
          input: "look",
          raw_output: complex_output
        )
      end

      it "returns output with prompt removed and double newlines" do
        expected = " Forest Path                                        Score: 25       Moves: 10\n\nForest Path\nYou are on a winding forest path. Tall trees tower above you,\ntheir leaves rustling in the gentle breeze."
        expect(formatter.to_s).to eq("#{expected}\n\n")
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

      let(:formatter) { described_class.new(system_result) }

      it "returns message with double newlines" do
        expect(formatter.to_s).to eq("Game saved successfully\n\n")
      end
    end

    context "with no message and empty raw output" do
      let(:empty_result) do
        TextPlayer::CommandResult.new(
          input: "test",
          raw_output: ""
        )
      end

      let(:formatter) { described_class.new(empty_result) }

      it "returns double newlines for empty content" do
        expect(formatter.to_s).to eq("\n\n")
      end
    end
  end

  describe "#to_h" do
    it "returns base command result data" do
      hash = formatter.to_h
      expect(hash[:input]).to eq("look")
      expect(hash[:raw_output]).to eq(game_output)
      expect(hash[:operation]).to eq(:game)
      expect(hash[:success]).to be true
    end
  end

  describe "#write" do
    it "writes to_s content to stream" do
      stream = StringIO.new
      formatter.write(stream)
      expect(stream.string).to eq("You are in a dark room.\n\n")
    end

    it "handles empty output" do
      empty_result = TextPlayer::CommandResult.new(
        input: "test",
        raw_output: ""
      )
      empty_formatter = described_class.new(empty_result)

      stream = StringIO.new
      empty_formatter.write(stream)
      expect(stream.string).to eq("\n\n")
    end
  end
end
