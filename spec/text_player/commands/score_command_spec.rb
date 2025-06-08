# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Commands::ScoreCommand do
  subject(:command) { described_class.new }

  let(:mock_process) { instance_double(TextPlayer::Dfrotz) }

  it "has the correct input" do
    expect(command.input).to eq("score")
  end

  it "executes score command successfully" do
    allow(mock_process).to receive(:write).with("score")
    allow(mock_process).to receive(:read_until).with(TextPlayer::PROMPT_REGEX).and_return("Score: 0 (total out of 350)\n>")

    result = command.execute(mock_process)

    expect(result.input).to eq("score")
    expect(result.operation).to eq(:score)
    expect(result.success).to be true
    expect(result.raw_output).to eq("Score: 0 (total out of 350)\n>")
    expect(result.message).to eq("Score: 0/350")
    expect(result.score).to eq("0")
    expect(result.out_of).to eq("350")
  end

  it "parses score without maximum" do
    allow(mock_process).to receive(:write).with("score")
    allow(mock_process).to receive(:read_until).with(TextPlayer::PROMPT_REGEX).and_return("Your score is 42 points.\n>")

    result = command.execute(mock_process)

    expect(result.success).to be true
    expect(result.message).to eq("Score: 42/")
    expect(result.score).to eq("42")
    expect(result.out_of).to be_nil
  end

  it "handles score parsing failure" do
    allow(mock_process).to receive(:write).with("score")
    allow(mock_process).to receive(:read_until).with(TextPlayer::PROMPT_REGEX).and_return("No score available.\n>")

    result = command.execute(mock_process)

    expect(result.operation).to eq(:score)
    expect(result.success).to be false
    expect(result.message).to eq("Score not found in output")
    expect(result.score).to be_nil
    expect(result.out_of).to be_nil
  end
end
