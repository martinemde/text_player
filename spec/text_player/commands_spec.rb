# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Commands do
  describe ".create" do
    it "creates Score for score input" do
      command = described_class.create("score", game_name: "zork1")
      expect(command).to be_a(TextPlayer::Commands::Score)
      expect(command.input).to eq("score")
    end

    it "creates Action for generic input" do
      command = described_class.create("look", game_name: "zork1")
      expect(command).to be_a(TextPlayer::Commands::Action)
      expect(command.input).to eq("look")
    end

    it "creates Save for save input" do
      command = described_class.create("save", game_name: "zork1")
      expect(command).to be_a(TextPlayer::Commands::Save)
      expect(command.savefile.filename).to eq("saves/zork1_autosave.qzl")
      expect(command.savefile.slot).to eq(TextPlayer::AUTO_SAVE_SLOT)
    end

    it "creates Save for save input with argument" do
      command = described_class.create("save checkpoint", game_name: "zork1")
      expect(command).to be_a(TextPlayer::Commands::Save)
      expect(command.savefile.filename).to eq("saves/zork1_checkpoint.qzl")
      expect(command.savefile.slot).to eq("checkpoint")
    end

    it "creates Restore for restore input" do
      command = described_class.create("restore", game_name: "zork1")
      expect(command).to be_a(TextPlayer::Commands::Restore)
      expect(command.input).to eq("restore")
      expect(command.savefile.filename).to eq("saves/zork1_autosave.qzl")
      expect(command.savefile.slot).to eq(TextPlayer::AUTO_SAVE_SLOT)
    end

    it "creates Restore with slot for restore with argument" do
      command = described_class.create("restore checkpoint", game_name: "zork1")
      expect(command).to be_a(TextPlayer::Commands::Restore)
      expect(command.savefile.filename).to eq("saves/zork1_checkpoint.qzl")
      expect(command.savefile.slot).to eq("checkpoint")
    end

    it "creates Quit for quit input" do
      command = described_class.create("quit", game_name: "zork1")
      expect(command).to be_a(TextPlayer::Commands::Quit)
      expect(command.input).to eq("quit")
    end

    it "handles case insensitive input" do
      save_command = described_class.create("SAVE", game_name: "zork1")
      expect(save_command).to be_a(TextPlayer::Commands::Save)

      quit_command = described_class.create("Quit", game_name: "zork1")
      expect(quit_command).to be_a(TextPlayer::Commands::Quit)
    end

    it "handles whitespace in input" do
      command = described_class.create("  save  ", game_name: "zork1")
      expect(command).to be_a(TextPlayer::Commands::Save)
    end
  end
end
