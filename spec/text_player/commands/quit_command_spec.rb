# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Commands::QuitCommand do
  subject(:command) { described_class.new }

  let(:mock_process) { instance_double(TextPlayer::Dfrotz) }

  it "has the correct input" do
    expect(command.input).to eq("quit")
  end

  it "executes quit operation" do
    allow(mock_process).to receive(:running?).and_return(true)
    allow(mock_process).to receive(:write).with("quit")
    allow(mock_process).to receive(:write).with("y")
    allow(mock_process).to receive(:terminate)

    result = command.execute(mock_process)

    expect(result.operation).to eq(:quit)
    expect(result.success).to be true
    expect(result.message).to eq("Game quit successfully")
  end

  it "handles broken pipe gracefully" do
    allow(mock_process).to receive(:running?).and_return(true)
    allow(mock_process).to receive(:write).with("quit")
    allow(mock_process).to receive(:write).with("y").and_raise(Errno::EPIPE)
    allow(mock_process).to receive(:terminate)

    result = command.execute(mock_process)

    expect(result.operation).to eq(:quit)
    expect(result.success).to be true
    expect(result.message).to eq("Game quit successfully")
  end
end
