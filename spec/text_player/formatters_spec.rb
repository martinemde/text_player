# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Formatter do
  let(:successful_output) do
    "Forest Path           Score: 25     Moves: 10\n\nForest Path\nYou are on a forest path.\n\n>"
  end

  let(:failed_output) do
    "That's not a verb I recognize.\n>"
  end

  let(:successful_result) do
    TextPlayer::CommandResult.new(
      operation: :action,
      success: true,
      input: "look",
      raw_output: successful_output
    )
  end

  let(:failed_result) do
    TextPlayer::CommandResult.new(
      operation: :action,
      success: false,
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

  describe ".by_name" do
    it "returns Json formatter for :json" do
      expect(described_class.by_name(:json)).to eq(TextPlayer::Formatter::Json)
    end

    it "returns Shell formatter for :shell" do
      expect(described_class.by_name(:shell)).to eq(TextPlayer::Formatter::Shell)
    end

    it "returns Text formatter for :text" do
      expect(described_class.by_name(:text)).to eq(TextPlayer::Formatter::Text)
    end

    it "returns Text formatter for unknown formatter names" do
      expect(described_class.by_name(:unknown)).to eq(TextPlayer::Formatter::Text)
      expect(described_class.by_name(:invalid)).to eq(TextPlayer::Formatter::Text)
      expect(described_class.by_name(nil)).to eq(TextPlayer::Formatter::Text)
    end

    it "returns Text formatter for non-symbol inputs" do
      expect(described_class.by_name("json")).to eq(TextPlayer::Formatter::Text)
      expect(described_class.by_name(123)).to eq(TextPlayer::Formatter::Text)
    end
  end
end
