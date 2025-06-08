# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Commands::SaveCommand do
  subject(:command) { described_class.new(save: TextPlayer::Save.new(game_filename: "zork1.z5")) }

  let(:mock_process) { instance_double(TextPlayer::Dfrotz) }

  it "executes save operation successfully" do
    allow(mock_process).to receive(:running?).and_return(true)
    allow(mock_process).to receive(:write).ordered.with("save")
    allow(mock_process).to receive(:read_until).ordered.and_return("")
    allow(mock_process).to receive(:write).ordered.with("saves/zork1_autosave.qzl")
    allow(mock_process).to receive(:read_until).ordered.and_return("Ok.")

    result = command.execute(mock_process)

    expect(result.operation).to eq(:save)
    expect(result.success).to be true
    expect(result.message).to eq("Game saved successfully")
    expect(result.filename).to eq("saves/zork1_autosave.qzl")
    expect(result.slot).to eq(TextPlayer::AUTO_SAVE_SLOT)
  end

  it "handles save failure" do
    allow(mock_process).to receive(:running?).and_return(true)
    allow(mock_process).to receive(:write).ordered.with("save")
    allow(mock_process).to receive(:read_until).ordered.and_return("")
    allow(mock_process).to receive(:write).ordered.with("saves/zork1_autosave.qzl")
    allow(mock_process).to receive(:read_until).ordered.and_return("Failed.")

    result = command.execute(mock_process)

    expect(result.operation).to eq(:save)
    expect(result.success).to be false
    expect(result.message).to eq("Save operation failed")
    expect(result.filename).to eq("saves/zork1_autosave.qzl")
  end
end
