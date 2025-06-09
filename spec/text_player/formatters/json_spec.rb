# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Formatters::Json do
  let(:game_output) do
    " Treasure Room                                       Score: 150      Moves: 25\n\nTreasure Room\nYou are in a glittering treasure room filled with gold and jewels.\nA massive chest sits in the center of the room.\n\n>"
  end

  let(:command_result) do
    TextPlayer::CommandResult.new(
      operation: :action,
      success: true,
      input: "look",
      raw_output: game_output
    )
  end

  let(:formatter) { described_class.new(command_result) }

  describe "#to_s" do
    it "returns valid JSON string" do
      json_string = formatter.to_s
      expect { JSON.parse(json_string) }.not_to raise_error
    end

    it "includes all data formatter fields in JSON" do
      json_string = formatter.to_s
      parsed = JSON.parse(json_string)

      expect(parsed["input"]).to eq("look")
      expect(parsed["operation"]).to eq("action")
      expect(parsed["success"]).to be true
      expect(parsed["location"]).to eq("Treasure Room")
      expect(parsed["score"]).to eq(150)
      expect(parsed["moves"]).to eq(25)
      expect(parsed["has_prompt"]).to be true
      expect(parsed["output"]).to include("glittering treasure room")
    end

    context "with time field" do
      let(:timed_output) do
        " Castle Gate                                         3:15 PM     Score: 50\n\nCastle Gate\nYou stand before an imposing castle gate.\n>"
      end

      let(:command_result) do
        TextPlayer::CommandResult.new(
          operation: :action,
          success: true,
          input: "look",
          raw_output: timed_output
        )
      end

      it "includes time field in JSON when present" do
        json_string = formatter.to_s
        parsed = JSON.parse(json_string)

        expect(parsed["time"]).to eq("3:15 PM")
        expect(parsed["location"]).to eq("Castle Gate")
        expect(parsed["score"]).to eq(50)
      end
    end

    context "with failed command" do
      let(:failed_output) { "I don't understand that command.\n>" }
      let(:failed_result) do
        TextPlayer::CommandResult.new(
          operation: :action,
          success: false,
          input: "invalid",
          raw_output: failed_output
        )
      end

      let(:formatter) { described_class.new(failed_result) }

      it "includes failure information in JSON" do
        json_string = formatter.to_s
        parsed = JSON.parse(json_string)

        expect(parsed["success"]).to be false
        expect(parsed["location"]).to be_nil
        expect(parsed["score"]).to be_nil
        expect(parsed["output"]).to include("don't understand")
      end
    end

    context "with system command" do
      let(:system_result) do
        TextPlayer::CommandResult.new(
          input: "save test.sav",
          operation: :save,
          success: true,
          message: "Game saved",
          filename: "test.sav",
          raw_output: ""
        )
      end

      let(:formatter) { described_class.new(system_result) }

      it "includes system command data in JSON" do
        json_string = formatter.to_s
        parsed = JSON.parse(json_string)

        expect(parsed["input"]).to eq("save test.sav")
        expect(parsed["operation"]).to eq("save")
        expect(parsed["success"]).to be true
        expect(parsed["message"]).to eq("Game saved")
        expect(parsed["filename"]).to eq("test.sav")
      end
    end

    context "with minimal game output" do
      let(:minimal_output) { "Ok.\n>" }
      let(:command_result) do
        TextPlayer::CommandResult.new(
          operation: :action,
          success: true,
          input: "take key",
          raw_output: minimal_output
        )
      end

      it "handles minimal output gracefully" do
        json_string = formatter.to_s
        parsed = JSON.parse(json_string)

        expect(parsed["input"]).to eq("take key")
        expect(parsed["location"]).to be_nil
        expect(parsed["score"]).to be_nil
        expect(parsed["moves"]).to be_nil
        expect(parsed["time"]).to be_nil
        expect(parsed["output"]).to eq("Ok.")
        expect(parsed["has_prompt"]).to be true
      end
    end
  end

  describe "#to_h" do
    it "returns same data as Data#to_h" do
      data_formatter = TextPlayer::Formatters::Data.new(command_result)

      expect(formatter.to_h).to eq(data_formatter.to_h)
    end
  end

  describe "#write" do
    it "writes JSON string to stream" do
      stream = StringIO.new
      formatter.write(stream)

      expect { JSON.parse(stream.string) }.not_to raise_error
      parsed = JSON.parse(stream.string)
      expect(parsed["location"]).to eq("Treasure Room")
    end
  end

  describe "JSON structure consistency" do
    it "maintains consistent field types across different outputs" do
      outputs = [
        " Room A     Score: 0    Moves: 1\nDescription A\n>",
        " Room B     Score: 10   Moves: 2\nDescription B\n>",
        "Error message\n>"
      ]

      json_objects = outputs.map do |output|
        result = TextPlayer::CommandResult.new(
          operation: :action,
          success: true,
          input: "test",
          raw_output: output
        )
        formatter = described_class.new(result)
        JSON.parse(formatter.to_s)
      end

      # Check that all objects have same field types
      json_objects.each do |obj|
        expect(obj["input"]).to be_a(String)
        expect(obj["operation"]).to be_a(String)
        expect([true, false]).to include(obj["success"])
        expect(obj["raw_output"]).to be_a(String)
        expect(obj["output"]).to be_a(String)
        expect([true, false]).to include(obj["has_prompt"])
        # Optional fields should be nil or correct type
        expect(obj["location"]).to be_a(String).or be_nil
        expect(obj["score"]).to be_a(Integer).or be_nil
        expect(obj["moves"]).to be_a(Integer).or be_nil
        expect(obj["time"]).to be_a(String).or be_nil
      end
    end
  end
end
