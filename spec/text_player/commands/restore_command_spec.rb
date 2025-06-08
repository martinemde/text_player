# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Commands::RestoreCommand do
  subject(:command) { described_class.new(save: save) }

  let(:save) { instance_double(TextPlayer::Save, exist?: true, slot: "save1", filename: "saves/zork1_save1.qzl") }
  let(:mock_process) { instance_double(TextPlayer::Dfrotz) }

  it "returns failure when save file doesn't exist" do
    allow(save).to receive(:exist?).and_return(false)

    result = command.execute(mock_process)

    expect(result.operation).to eq(:restore)
    expect(result.success).to be false
    expect(result.message).to eq("Restore failed - file not found")
    expect(result.filename).to eq("saves/zork1_save1.qzl")
    expect(result.slot).to eq("save1")
  end

  it "executes restore operation successfully" do
    allow(mock_process).to receive(:write).with("restore")
    allow(mock_process).to receive(:read_until).with(TextPlayer::FILENAME_PROMPT_REGEX).and_return("")
    allow(mock_process).to receive(:write).with("saves/zork1_save1.qzl")
    allow(mock_process).to receive(:read_until).with(/Ok\.|Failed\.|not found|>/i).and_return("Ok.")

    result = command.execute(mock_process)

    expect(result.operation).to eq(:restore)
    expect(result.success).to be true
    expect(result.message).to eq("Game restored successfully")
    expect(result.filename).to eq("saves/zork1_save1.qzl")
    expect(result.slot).to eq("save1")
  end

  it "handles restore failure" do
    allow(mock_process).to receive(:write).with("restore")
    allow(mock_process).to receive(:read_until).with(TextPlayer::FILENAME_PROMPT_REGEX).and_return("")
    allow(mock_process).to receive(:write).with("saves/zork1_save1.qzl")
    allow(mock_process).to receive(:read_until).with(/Ok\.|Failed\.|not found|>/i).and_return("Failed.")

    result = command.execute(mock_process)

    expect(result.operation).to eq(:restore)
    expect(result.success).to be false
    expect(result.message).to eq("Restore failed - file not found by dfrotz process even though it existed before running this command")
    expect(result.filename).to eq("saves/zork1_save1.qzl")
    expect(result.slot).to eq("save1")
  end

  it "handles file not found by dfrotz" do
    allow(mock_process).to receive(:write).with("restore")
    allow(mock_process).to receive(:read_until).with(TextPlayer::FILENAME_PROMPT_REGEX).and_return("")
    allow(mock_process).to receive(:write).with("saves/zork1_save1.qzl")
    allow(mock_process).to receive(:read_until).with(/Ok\.|Failed\.|not found|>/i).and_return("not found")

    result = command.execute(mock_process)

    expect(result.operation).to eq(:restore)
    expect(result.success).to be false
    expect(result.message).to eq("Restore failed - file not found by dfrotz process even though it existed before running this command")
  end

  it "handles other responses" do
    allow(mock_process).to receive(:write).with("restore")
    allow(mock_process).to receive(:read_until).with(TextPlayer::FILENAME_PROMPT_REGEX).and_return("")
    allow(mock_process).to receive(:write).with("saves/zork1_save1.qzl")
    allow(mock_process).to receive(:read_until).with(/Ok\.|Failed\.|not found|>/i).and_return(">")

    result = command.execute(mock_process)

    expect(result.operation).to eq(:restore)
    expect(result.success).to be false
    expect(result.message).to eq("Restore operation completed")
  end
end
