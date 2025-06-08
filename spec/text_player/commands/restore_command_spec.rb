# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Commands::RestoreCommand do
  subject(:command) { described_class.new(input: "restore", slot: "autosave", game_filename: "zork1.z5") }

  let(:mock_process) { instance_double(TextPlayer::Dfrotz) }

  it "executes restore operation successfully" do
    allow(mock_process).to receive(:running?).and_return(true)
    allow(mock_process).to receive(:write).with("restore")
    allow(mock_process).to receive(:read_until).and_return("")
    allow(mock_process).to receive(:write).with("saves/zork1_autosave.qzl")
    allow(mock_process).to receive(:read_until).and_return("Ok.")

    result = command.execute(mock_process)

    expect(result.operation).to eq(:restore)
    expect(result.success).to be true
    expect(result.message).to eq("Game restored successfully")
    expect(result.details[:slot]).to eq("autosave")
    expect(result.details[:filename]).to eq("saves/zork1_autosave.qzl")
  end

  it "handles restore failure" do
    allow(mock_process).to receive(:running?).and_return(true)
    allow(mock_process).to receive(:write).with("restore")
    allow(mock_process).to receive(:read_until).and_return("")
    allow(mock_process).to receive(:write).with("saves/zork1_autosave.qzl")
    allow(mock_process).to receive(:read_until).and_return("Failed.")

    result = command.execute(mock_process)

    expect(result.operation).to eq(:restore)
    expect(result.success).to be false
    expect(result.message).to eq("Restore failed - file not found or corrupted")
  end

  it "returns error when process is not running" do
    allow(mock_process).to receive(:running?).and_return(false)

    result = command.execute(mock_process)

    expect(result.input).to eq("restore")
    expect(result.operation).to eq(:error)
    expect(result.success).to be false
    expect(result.message).to eq("Game not running")
  end
end
