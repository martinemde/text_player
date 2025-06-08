# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Commands::SaveCommand do
  subject(:command) { described_class.new(input: "save", slot: "autosave", game_filename: "zork1.z5") }

  let(:mock_process) { instance_double(TextPlayer::Dfrotz) }

  it "executes save operation successfully" do
    allow(mock_process).to receive(:running?).and_return(true)
    allow(mock_process).to receive(:write).with("save")
    allow(mock_process).to receive(:read_until).and_return("")
    allow(mock_process).to receive(:write).with("saves/zork1_autosave.qzl")
    allow(mock_process).to receive(:read_until).and_return("Ok.")

    result = command.execute(mock_process)

    expect(result.operation).to eq(:save)
    expect(result.success).to be true
    expect(result.message).to eq("Game saved successfully")
    expect(result.details[:slot]).to eq("autosave")
    expect(result.details[:filename]).to eq("saves/zork1_autosave.qzl")
  end

  it "handles save failure" do
    allow(mock_process).to receive(:running?).and_return(true)
    allow(mock_process).to receive(:write).with("save")
    allow(mock_process).to receive(:read_until).and_return("")
    allow(mock_process).to receive(:write).with("saves/zork1_autosave.qzl")
    allow(mock_process).to receive(:read_until).and_return("Failed.")

    result = command.execute(mock_process)

    expect(result.operation).to eq(:save)
    expect(result.success).to be false
    expect(result.message).to eq("Save operation failed")
  end

  it "returns error when process is not running" do
    allow(mock_process).to receive(:running?).and_return(false)

    result = command.execute(mock_process)

    expect(result.input).to eq("save")
    expect(result.operation).to eq(:error)
    expect(result.success).to be false
    expect(result.message).to eq("Game not running")
  end
end
