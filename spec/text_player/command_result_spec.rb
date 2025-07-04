# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::CommandResult do
  describe "#initialize" do
    it "creates a game command result by default" do
      result = described_class.new(input: "look", raw_output: "You see nothing special.")

      expect(result.input).to eq("look")
      expect(result.raw_output).to eq("You see nothing special.")
      expect(result.operation).to eq(:action)
      expect(result.success).to be true
      expect(result.message).to be_nil
      expect(result.details).to eq({})
    end

    it "creates a system command result" do
      result = described_class.new(
        input: "save",
        operation: :save,
        success: true,
        message: "Game saved successfully",
        slot: "autosave",
        filename: "saves/game_autosave.qzl"
      )

      expect(result.input).to eq("save")
      expect(result.operation).to eq(:save)
      expect(result.success).to be true
      expect(result.message).to eq("Game saved successfully")
      expect(result.details[:slot]).to eq("autosave")
      expect(result.details[:filename]).to eq("saves/game_autosave.qzl")
    end

    it "creates a start command result with empty input" do
      result = described_class.new(
        input: "",
        raw_output: "Welcome to the game!\n>",
        operation: :start,
        success: true
      )

      expect(result.input).to eq("")
      expect(result.raw_output).to eq("Welcome to the game!\n>")
      expect(result.operation).to eq(:start)
      expect(result.success).to be true
    end

    it "creates successful result for valid game output" do
      result = described_class.new(
        operation: :action,
        input: "look",
        raw_output: "Forest Path\nYou are in a forest.\n>"
      )

      expect(result.input).to eq("look")
      expect(result.operation).to eq(:action)
      expect(result.success).to be true
    end

    it "creates failed result when failure patterns are detected" do
      result = described_class.new(
        input: "fart",
        operation: :action,
        success: false,
        raw_output: "That's not a verb I recognize.\n\n>"
      )

      expect(result.input).to eq("fart")
      expect(result.operation).to eq(:action)
      expect(result.success).to be false
      expect(result.message).to be_nil
    end

    it "creates successful result for non-game operations" do
      result = described_class.new(
        input: "save",
        operation: :save,
        success: true,
        raw_output: "Failed output",
        filename: "test.sav"
      )

      expect(result.operation).to eq(:save)
      expect(result.success).to be true # Non-game operations default to success
      expect(result.details[:filename]).to eq("test.sav")
    end
  end

  describe "#action_command?" do
    it "returns true for game commands" do
      result = described_class.new(input: "look", operation: :action)
      expect(result.action_command?).to be true
    end

    it "returns false for system commands" do
      result = described_class.new(input: "save", operation: :save)
      expect(result.action_command?).to be false
    end
  end

  describe "#system_command?" do
    it "returns false for game commands" do
      result = described_class.new(input: "look", operation: :action)
      expect(result.system_command?).to be false
    end

    it "returns true for system commands" do
      result = described_class.new(input: "save", operation: :save)
      expect(result.system_command?).to be true
    end
  end

  describe "#success?" do
    it "returns true when success is true" do
      result = described_class.new(input: "save", success: true)
      expect(result).to be_success
    end

    it "returns false when success is false" do
      result = described_class.new(input: "save", success: false)
      expect(result).not_to be_success
    end
  end

  describe "#failure?" do
    it "returns false when success is true" do
      result = described_class.new(input: "save", success: true)
      expect(result).not_to be_failure
    end

    it "returns true when success is false" do
      result = described_class.new(input: "save", success: false)
      expect(result).to be_failure
    end
  end
end
