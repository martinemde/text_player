# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Commands do
  describe ".create" do
    it "creates ScoreCommand for score input" do
      command = described_class.create("score", game_filename: "zork1.z5")
      expect(command).to be_a(TextPlayer::Commands::ScoreCommand)
      expect(command.input).to eq("score")
    end

    it "creates ActionCommand for generic input" do
      command = described_class.create("look", game_filename: "zork1.z5")
      expect(command).to be_a(TextPlayer::Commands::ActionCommand)
      expect(command.input).to eq("look")
    end

    it "creates SaveCommand for save input" do
      command = described_class.create("save", game_filename: "zork1.z5")
      expect(command).to be_a(TextPlayer::Commands::SaveCommand)
      expect(command.save.filename).to eq("saves/zork1_autosave.qzl")
      expect(command.save.slot).to eq(TextPlayer::AUTO_SAVE_SLOT)
    end

    it "creates SaveCommand for save input with argument" do
      command = described_class.create("save checkpoint", game_filename: "zork1.z5")
      expect(command).to be_a(TextPlayer::Commands::SaveCommand)
      expect(command.save.filename).to eq("saves/zork1_checkpoint.qzl")
      expect(command.save.slot).to eq("checkpoint")
    end

    it "creates RestoreCommand for restore input" do
      command = described_class.create("restore", game_filename: "zork1.z5")
      expect(command).to be_a(TextPlayer::Commands::RestoreCommand)
      expect(command.input).to eq("restore")
      expect(command.save.filename).to eq("saves/zork1_autosave.qzl")
      expect(command.save.slot).to eq(TextPlayer::AUTO_SAVE_SLOT)
    end

    it "creates RestoreCommand with slot for restore with argument" do
      command = described_class.create("restore checkpoint", game_filename: "zork1.z5")
      expect(command).to be_a(TextPlayer::Commands::RestoreCommand)
      expect(command.save.filename).to eq("saves/zork1_checkpoint.qzl")
      expect(command.save.slot).to eq("checkpoint")
    end

    it "creates QuitCommand for quit input" do
      command = described_class.create("quit", game_filename: "zork1.z5")
      expect(command).to be_a(TextPlayer::Commands::QuitCommand)
      expect(command.input).to eq("quit")
    end

    it "handles case insensitive input" do
      save_command = described_class.create("SAVE", game_filename: "zork1.z5")
      expect(save_command).to be_a(TextPlayer::Commands::SaveCommand)

      quit_command = described_class.create("Quit", game_filename: "zork1.z5")
      expect(quit_command).to be_a(TextPlayer::Commands::QuitCommand)
    end

    it "handles whitespace in input" do
      command = described_class.create("  save  ", game_filename: "zork1.z5")
      expect(command).to be_a(TextPlayer::Commands::SaveCommand)
    end
  end
end
