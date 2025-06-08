# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Commands::ScoreCommand do
  subject(:command) { described_class.new }

  let(:mock_process) { instance_double(TextPlayer::Dfrotz) }

  it "has the correct input" do
    expect(command.input).to eq("score")
  end

  it "executes score command when process is running" do
    allow(mock_process).to receive(:running?).and_return(true)
    allow(mock_process).to receive(:write).with("score")
    allow(mock_process).to receive(:read_until).with(TextPlayer::PROMPT_REGEX).and_return("Score: 0 (total out of 350)\n>")

    result = command.execute(mock_process)

    expect(result.input).to eq("score")
    expect(result.operation).to eq(:score)
    expect(result.success).to be true
    expect(result.raw_output).to eq("Score: 0 (total out of 350)\n>")
  end

  it "returns error when process is not running" do
    allow(mock_process).to receive(:running?).and_return(false)

    result = command.execute(mock_process)

    expect(result.input).to eq("score")
    expect(result.operation).to eq(:error)
    expect(result.success).to be false
    expect(result.message).to eq("Game not running")
  end
end
