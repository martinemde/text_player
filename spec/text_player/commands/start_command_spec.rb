# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Commands::StartCommand do
  subject(:command) { described_class.new }

  let(:mock_process) { instance_double(TextPlayer::Dfrotz) }

  it "has nil input" do
    expect(command.input).to be_nil
  end

  it "executes start operation successfully" do
    allow(mock_process).to receive(:read_until).with(TextPlayer::PROMPT_REGEX).and_return("Welcome to the game!\n>")

    result = command.execute(mock_process)

    expect(result.input).to be_nil
    expect(result.operation).to eq(:start)
    expect(result.success).to be true
    expect(result.message).to eq("Game started successfully")
    expect(result.raw_output).to eq("Welcome to the game!\n>")
  end

  it "handles press any key prompts" do
    allow(mock_process).to receive(:read_until).with(TextPlayer::PROMPT_REGEX)
      .and_return("Press any key to continue...", "More text follows...", "Game started!\n>")
    allow(mock_process).to receive(:write).with(" ").ordered
    allow(mock_process).to receive(:write).with(" ").ordered
    allow(mock_process).to receive(:write).with(" ").ordered

    result = command.execute(mock_process)

    expect(result.operation).to eq(:start)
    expect(result.success).to be true
    expect(result.message).to eq("Game started successfully")
  end

  it "skips introduction when offered" do
    allow(mock_process).to receive(:read_until).with(TextPlayer::PROMPT_REGEX)
      .and_return("Would you like to read the introduction?", "Game started!\n>")
    allow(mock_process).to receive(:write).with("no")

    result = command.execute(mock_process)

    expect(result.operation).to eq(:start)
    expect(result.success).to be true
    expect(result.message).to eq("Game started successfully")
  end

  it "handles both press key and introduction prompts" do
    allow(mock_process).to receive(:read_until).with(TextPlayer::PROMPT_REGEX)
      .and_return("Press any key...", "Would you like the introduction?", "Game started!\n>")
    allow(mock_process).to receive(:write).with(" ")
    allow(mock_process).to receive(:write).with("no")

    result = command.execute(mock_process)

    expect(result.operation).to eq(:start)
    expect(result.success).to be true
    expect(result.message).to eq("Game started successfully")
  end
end
