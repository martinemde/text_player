# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Formatters do
  let(:successful_output) do
    "Forest Path           Score: 25     Moves: 10\n\nForest Path\nYou are on a forest path.\n\n>"
  end

  let(:failed_output) do
    "That's not a verb I recognize.\n>"
  end

  let(:successful_result) do
    TextPlayer::CommandResult.from_game_output(
      input: "look",
      raw_output: successful_output
    )
  end

  let(:failed_result) do
    TextPlayer::CommandResult.from_game_output(
      input: "invalid",
      raw_output: failed_output
    )
  end

  let(:system_result) do
    TextPlayer::CommandResult.new(
      input: "save",
      operation: :save,
      success: true,
      message: "Game saved",
      slot: "test",
      filename: "test.sav"
    )
  end

  describe ".create" do
    it "creates the correct formatter type" do
      expect(described_class.create(:text, successful_result))
        .to be_a(TextPlayer::Formatters::Text)
      expect(described_class.create(:data, successful_result))
        .to be_a(TextPlayer::Formatters::Data)
      expect(described_class.create(:json, successful_result))
        .to be_a(TextPlayer::Formatters::Json)
      expect(described_class.create(:shell, successful_result))
        .to be_a(TextPlayer::Formatters::Shell)
    end
  end
end
