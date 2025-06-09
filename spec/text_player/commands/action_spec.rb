# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Commands::Action do
  subject(:command) { described_class.new(input: "command") }

  let(:mock_process) { instance_double(TextPlayer::Dfrotz) }

  it "executes game action" do
    allow(mock_process).to receive(:write).with("command")
    allow(mock_process).to receive(:read_until).with(TextPlayer::PROMPT_REGEX).and_return("You see nothing special.\n>")

    result = command.execute(mock_process)

    expect(result.input).to eq("command")
    expect(result.operation).to eq(:action)
    expect(result.success).to be true
    expect(result.raw_output).to eq("You see nothing special.\n>")
  end

  it "executes an invalid action" do
    allow(mock_process).to receive(:write).with("command")
    allow(mock_process).to receive(:read_until).with(TextPlayer::PROMPT_REGEX).and_return("That's not a verb I recognize.\n\n>")

    result = command.execute(mock_process)

    expect(result.input).to eq("command")
    expect(result.operation).to eq(:action)
    expect(result).not_to be_success
    expect(result.raw_output).to eq("That's not a verb I recognize.\n\n>")
  end

  describe ".failure_detected?" do
    it "detects various failure patterns" do
      failure_outputs = [
        "I don't understand that.",
        "You can't do that here.",
        "I can't see any such thing.",
        "That doesn't make sense.",
        "What do you want to examine?",
        "You don't see that here.",
        "There is no door here.",
        "I don't see anything special."
      ]

      failure_outputs.each do |output|
        allow(mock_process).to receive(:write).with("command")
        allow(mock_process).to receive(:read_until).with(TextPlayer::PROMPT_REGEX).and_return("#{output}\n\n>")

        result = command.execute(mock_process)

        expect(result).not_to be_success
      end
    end

    it "does not detect success as failure" do
      success_outputs = [
        "You are in the forest.",
        "You pick up the sword.",
        "The door opens.",
        "You see a beautiful garden."
      ]

      success_outputs.each do |output|
        allow(mock_process).to receive(:write).with("command")
        allow(mock_process).to receive(:read_until).with(TextPlayer::PROMPT_REGEX).and_return("#{output}\n\n>")

        result = command.execute(mock_process)

        expect(result).to be_success
      end
    end
  end
end
