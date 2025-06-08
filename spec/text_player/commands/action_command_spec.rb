# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Commands::ActionCommand do
  subject(:command) { described_class.new(input: "look") }

  let(:mock_process) { instance_double(TextPlayer::Dfrotz) }

  it "executes game action" do
    allow(mock_process).to receive(:write).with("look")
    allow(mock_process).to receive(:read_until).with(TextPlayer::PROMPT_REGEX).and_return("You see nothing special.\n>")

    result = command.execute(mock_process)

    expect(result.input).to eq("look")
    expect(result.operation).to eq(:game)
    expect(result.success).to be true
    expect(result.raw_output).to eq("You see nothing special.\n>")
  end
end
