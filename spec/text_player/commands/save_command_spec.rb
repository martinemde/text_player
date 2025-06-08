# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Commands::SaveCommand do
  subject(:command) { described_class.new(save: save) }

  let(:save) { instance_double(TextPlayer::Save, slot: "save1", filename: "saves/zork1_save1.qzl") }
  let(:mock_process) { instance_double(TextPlayer::Dfrotz) }

  it "executes save operation successfully" do
    allow(mock_process).to receive(:write).with("save")
    allow(mock_process).to receive(:read_until).with(TextPlayer::FILENAME_PROMPT_REGEX).and_return("")
    allow(mock_process).to receive(:write).with("saves/zork1_save1.qzl")
    allow(mock_process).to receive(:read_until).with(/Overwrite existing file\? |Ok\.|Failed\.|>/i).and_return("Ok.")

    result = command.execute(mock_process)

    expect(result.operation).to eq(:save)
    expect(result.success).to be true
    expect(result.message).to eq("Game saved successfully")
    expect(result.filename).to eq("saves/zork1_save1.qzl")
    expect(result.slot).to eq("save1")
  end

  it "handles overwrite scenario successfully" do
    allow(mock_process).to receive(:write).with("save")
    allow(mock_process).to receive(:read_until).with(TextPlayer::FILENAME_PROMPT_REGEX).and_return("")
    allow(mock_process).to receive(:write).with("saves/zork1_save1.qzl")
    allow(mock_process).to receive(:read_until).with(/Overwrite existing file\? |Ok\.|Failed\.|>/i).and_return("Overwrite existing file? ")
    allow(mock_process).to receive(:write).with("y")
    allow(mock_process).to receive(:read_until).with(/Ok\.|Failed\.|>/i).and_return("Ok.")

    result = command.execute(mock_process)

    expect(result.operation).to eq(:save)
    expect(result.success).to be true
    expect(result.message).to eq("Game saved successfully")
  end

  it "handles save failure" do
    allow(mock_process).to receive(:write).with("save")
    allow(mock_process).to receive(:read_until).with(TextPlayer::FILENAME_PROMPT_REGEX).and_return("")
    allow(mock_process).to receive(:write).with("saves/zork1_save1.qzl")
    allow(mock_process).to receive(:read_until).with(/Overwrite existing file\? |Ok\.|Failed\.|>/i).and_return("Failed.")

    result = command.execute(mock_process)

    expect(result.operation).to eq(:save)
    expect(result.success).to be false
    expect(result.message).to eq("Save operation failed")
    expect(result.filename).to eq("saves/zork1_save1.qzl")
    expect(result.slot).to eq("save1")
  end

  it "handles other responses" do
    allow(mock_process).to receive(:write).with("save")
    allow(mock_process).to receive(:read_until).with(TextPlayer::FILENAME_PROMPT_REGEX).and_return("")
    allow(mock_process).to receive(:write).with("saves/zork1_save1.qzl")
    allow(mock_process).to receive(:read_until).with(/Overwrite existing file\? |Ok\.|Failed\.|>/i).and_return(">")

    result = command.execute(mock_process)

    expect(result.operation).to eq(:save)
    expect(result.success).to be false
    expect(result.message).to eq("Save completed")
  end
end
