# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Formatters::Data do
  describe "#to_s and #to_h" do
    context "with canyon bottom format (location with score/moves on same line)" do
      let(:game_output) do
        " Canyon Bottom                                    Score: 0        Moves: 26\n\nCanyon Bottom\nYou are beneath the walls of the river canyon which may be climbable here. The\nlesser part of the runoff of Aragain Falls flows by below. To the north is a\nnarrow path.\n\n>"
      end

      let(:command_result) do
        TextPlayer::CommandResult.from_game_output(
          input: "look",
          raw_output: game_output
        )
      end

      let(:formatter) { described_class.new(command_result) }

      it "extracts location correctly" do
        expect(formatter.to_h[:location]).to eq("Canyon Bottom")
      end

      it "extracts score correctly" do
        expect(formatter.to_h[:score]).to eq(0)
      end

      it "extracts moves correctly" do
        expect(formatter.to_h[:moves]).to eq(26)
      end

      it "has prompt" do
        expect(formatter.to_h[:has_prompt]).to be true
      end

      it "cleans game text preserving description" do
        cleaned = formatter.to_h[:output]
        expect(cleaned).to include("Canyon Bottom")
        expect(cleaned).to include("You are beneath the walls")
        expect(cleaned).not_to include("Score: 0")
        expect(cleaned).not_to include("Moves: 26")
        expect(cleaned).not_to include(">")
      end
    end

    context "with brig format (location on separate line)" do
      let(:game_output) do
        " Brig\n Moves:0\n\nBrig\nYou're in a small, smooth-walled room with barely enough area to stand. A pair\nof simple bunk beds occupy most of the cramped space. There is a panel near the\ndoor. A faint smell of ozone is coming from the vent high above the beds. The\npirates must have started some electrical fires. The only door is north, but\nit's closed and locked.\n\n>"
      end

      let(:command_result) do
        TextPlayer::CommandResult.from_game_output(
          input: "look",
          raw_output: game_output
        )
      end

      let(:formatter) { described_class.new(command_result) }

      it "extracts location correctly" do
        expect(formatter.to_h[:location]).to eq("Brig")
      end

      it "extracts moves correctly" do
        expect(formatter.to_h[:moves]).to eq(0)
      end

      it "does not extract score when not present" do
        expect(formatter.to_h[:score]).to be_nil
      end

      it "cleans game text preserving description" do
        cleaned = formatter.to_h[:output]
        expect(cleaned).to include("Brig")
        expect(cleaned).to include("You're in a small, smooth-walled room")
        expect(cleaned).not_to include("Moves:0")
        expect(cleaned).not_to include(">")
      end
    end

    context "with enchanted forest format (location with time and score)" do
      let(:game_output) do
        " In the enchanted forest                             5:00 AM      Score: 0\n\nIn the enchanted forest\nA large wooden sign informs me that I'm in the Enchanted Forest. What it doesn't\ntell me is how the hell I get out! Everywhere I look there are trees, trees,\ntrees. This place definately has a 'tree' theme going. A clearly marked path\nleads south and west, whilst in every other direction are, well, trees.\nAn old pedlar is sitting on a log here, tending to his bunions.\n\n>"
      end

      let(:command_result) do
        TextPlayer::CommandResult.from_game_output(
          input: "look",
          raw_output: game_output
        )
      end

      let(:formatter) { described_class.new(command_result) }

      it "extracts location correctly" do
        expect(formatter.to_h[:location]).to eq("In the enchanted forest")
      end

      it "extracts time correctly" do
        expect(formatter.to_h[:time]).to eq("5:00 AM")
      end

      it "extracts score correctly" do
        expect(formatter.to_h[:score]).to eq(0)
      end

      it "cleans game text preserving all description" do
        cleaned = formatter.to_h[:output]
        expect(cleaned).to include("In the enchanted forest")
        expect(cleaned).to include("A large wooden sign")
        expect(cleaned).to include("An old pedlar is sitting")
        expect(cleaned).not_to include("5:00 AM")
        expect(cleaned).not_to include("Score: 0")
        expect(cleaned).not_to include(">")
      end
    end

    context "with error messages" do
      let(:game_output) { "I don't know the word \"fart\".\n\n>" }
      let(:command_result) do
        TextPlayer::CommandResult.from_game_output(
          input: "fart",
          raw_output: game_output
        )
      end

      let(:formatter) { described_class.new(command_result) }

      it "does not extract location from error messages" do
        expect(formatter.to_h[:location]).to be_nil
      end

      it "preserves error message in output" do
        cleaned = formatter.to_h[:output]
        expect(cleaned).to include("don't know the word")
        expect(cleaned).not_to include(">")
      end

      it "detects failure" do
        expect(command_result.success?).to be false
      end
    end

    context "with different error patterns" do
      [
        "I beg your pardon?",
        "You can't go that way.",
        "That's not a verb I recognise.",
        "You don't see that here."
      ].each do |error_msg|
        context "with error: #{error_msg}" do
          let(:game_output) { "#{error_msg}\n\n>" }
          let(:command_result) do
            TextPlayer::CommandResult.from_game_output(
              input: "test",
              raw_output: game_output
            )
          end

          let(:formatter) { described_class.new(command_result) }

          it "does not extract location from error message" do
            expect(formatter.to_h[:location]).to be_nil
          end

          it "preserves error message" do
            expect(formatter.to_h[:output]).to include(error_msg)
          end
        end
      end
    end

    context "with no extracted data" do
      let(:game_output) { "Simple response without location or stats.\n>" }
      let(:command_result) do
        TextPlayer::CommandResult.from_game_output(
          input: "test",
          raw_output: game_output
        )
      end

      let(:formatter) { described_class.new(command_result) }

      it "returns nil for unextracted fields" do
        data = formatter.to_h
        expect(data[:location]).to be_nil
        expect(data[:score]).to be_nil
        expect(data[:moves]).to be_nil
        expect(data[:time]).to be_nil
      end

      it "preserves all content in output since nothing was extracted" do
        expect(formatter.to_h[:output]).to eq("Simple response without location or stats.")
      end
    end

    context "with partial data" do
      let(:game_output) { " Forest                                              Score: 42\n\nYou are in a dark forest.\n>" }
      let(:command_result) do
        TextPlayer::CommandResult.from_game_output(
          input: "look",
          raw_output: game_output
        )
      end

      let(:formatter) { described_class.new(command_result) }

      it "extracts only available data" do
        data = formatter.to_h
        expect(data[:location]).to eq("Forest")
        expect(data[:score]).to eq(42)
        expect(data[:moves]).to be_nil
        expect(data[:time]).to be_nil
      end

      it "cleans only what was extracted" do
        cleaned = formatter.to_h[:output]
        expect(cleaned).to include("Forest")
        expect(cleaned).to include("You are in a dark forest")
        expect(cleaned).not_to include("Score: 42")
      end
    end
  end

  describe "#to_s" do
    let(:game_output) do
      " Test Location                                       Score: 100      Moves: 5\n\nTest Location\nDescription here.\n>"
    end

    let(:command_result) do
      TextPlayer::CommandResult.from_game_output(
        input: "look",
        raw_output: game_output
      )
    end

    let(:formatter) { described_class.new(command_result) }

    it "joins all non-nil parsed values with newlines" do
      result = formatter.to_s
      expect(result).to include("Test Location")
      expect(result).to include("100")
      expect(result).to include("5")
      expect(result).to include("Description here")
    end
  end

  describe "preservation of unextracted data" do
    let(:game_output) do
      " Complex Location                                     Score: 10\n\nComplex Location\nFirst paragraph of description.\n\nSecond paragraph with more details.\nAnd even more text here.\n\nFinal paragraph.\n>"
    end

    let(:command_result) do
      TextPlayer::CommandResult.from_game_output(
        input: "look",
        raw_output: game_output
      )
    end

    let(:formatter) { described_class.new(command_result) }

    it "preserves all paragraphs in cleaned output" do
      cleaned = formatter.to_h[:output]
      expect(cleaned).to include("Complex Location")
      expect(cleaned).to include("First paragraph")
      expect(cleaned).to include("Second paragraph")
      expect(cleaned).to include("Final paragraph")
      expect(cleaned).not_to include("Score: 10")
      expect(cleaned).not_to include(">")
    end

    it "maintains paragraph structure" do
      cleaned = formatter.to_h[:output]
      paragraphs = cleaned.split("\n\n")
      expect(paragraphs.length).to be >= 3
    end
  end
end
