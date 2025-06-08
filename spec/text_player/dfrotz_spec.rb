# frozen_string_literal: true

require "spec_helper"

RSpec.describe TextPlayer::Dfrotz do
  # Class method tests that don't require instances
  describe ".path" do
    around(:each) do |example|
      original_env = ENV["DFROTZ_PATH"]
      example.run
    ensure
      if original_env
        ENV["DFROTZ_PATH"] = original_env
      else
        ENV.delete("DFROTZ_PATH")
      end
    end

    it "returns the default system path when DFROTZ_PATH is not set" do
      ENV.delete("DFROTZ_PATH")
      expect(described_class.path).to eq("dfrotz")
    end

    it "returns the DFROTZ_PATH environment variable when set" do
      ENV["DFROTZ_PATH"] = "/custom/path/dfrotz"
      expect(described_class.path).to eq("/custom/path/dfrotz")
    end
  end

  describe ".executable?" do
    it "returns true for a valid executable path" do
      # Test with the actual dfrotz path if available
      if described_class.executable?
        expect(described_class.executable?(described_class.path)).to be true
      else
        skip "dfrotz not available for testing"
      end
    end

    it "returns false for a non-existent path" do
      expect(described_class.executable?("/non/existent/path")).to be false
    end

    it "returns false for a non-executable file" do
      # Create a temporary non-executable file
      require "tempfile"
      Tempfile.create("non_executable") do |file|
        file.write("not executable")
        file.close
        File.chmod(0o644, file.path) # Make it non-executable
        expect(described_class.executable?(file.path)).to be false
      end
    end

    it "uses system 'which' command as fallback" do
      # Test that it can find commands in PATH
      expect(described_class.executable?("ls")).to be true
    end
  end

  # Instance tests that require dfrotz to be available
  context "when dfrotz is available" do
    let(:game_path) { TextPlayer::GameUtils.full_path("zork1.z5") }
    let(:dfrotz) { described_class.new(game_path) }

    before do
      # Skip tests if dfrotz is not available
      skip "dfrotz not found at #{described_class.path}" unless described_class.executable?
      skip "zork1.z5 not found at #{game_path}" unless File.exist?(game_path)
    end

    after do
      dfrotz.terminate if dfrotz.running?
    end

    describe "#initialize" do
      it "creates a new Dfrotz instance" do
        expect(dfrotz).to be_a(described_class)
      end

      it "accepts custom timeout and command_delay" do
        df = described_class.new(game_path, timeout: 2, command_delay: 0.2)
        expect(df).to be_a(described_class)
      end

      it "accepts custom dfrotz path" do
        if described_class.executable?
          df = described_class.new(game_path, dfrotz: described_class.path)
          expect(df).to be_a(described_class)
        else
          skip "dfrotz not available for testing"
        end
      end

      it "raises error when dfrotz path is not found" do
        expect {
          described_class.new(game_path, dfrotz: "/non/existent/dfrotz")
        }.to raise_error(RuntimeError, /dfrotz not found/)
      end

      it "raises error when dfrotz path is not executable" do
        # Create a temporary non-executable file
        require "tempfile"
        Tempfile.create("fake_dfrotz") do |file|
          file.write("not dfrotz")
          file.close
          File.chmod(0o644, file.path) # Make it non-executable

          expect {
            described_class.new(game_path, dfrotz: file.path)
          }.to raise_error(RuntimeError, /dfrotz not found/)
        end
      end
    end

    describe "#start" do
      it "returns true if already running" do
        expect(dfrotz.start).to be true
        expect(dfrotz.start).to be true
      end
    end

    describe "#running?" do
      it "returns false when not started" do
        expect(dfrotz).not_to be_running
      end

      it "returns true when started" do
        dfrotz.start
        expect(dfrotz).to be_running
      end

      it "returns false after termination" do
        dfrotz.start
        dfrotz.terminate
        expect(dfrotz).not_to be_running
      end
    end

    describe "#write" do
      it "returns false when not running" do
        expect(dfrotz.write("look")).to be false
      end

      it "returns true when successfully writing" do
        dfrotz.start
        expect(dfrotz.write("look")).to be true
      end
    end

    describe "#read_all" do
      it "returns empty string when not running" do
        expect(dfrotz.read_all).to eq("")
      end

      it "reads initial game output" do
        dfrotz.start
        output = dfrotz.read_all
        expect(output).to include("ZORK I: The Great Underground Empire")
        expect(output).to include("West of House")
      end
    end

    describe "#read_until" do
      it "returns empty string when not running" do
        expect(dfrotz.read_until(/^>/)).to eq("")
      end

      it "reads until pattern is found" do
        dfrotz.start
        output = dfrotz.read_until(/^>/)
        expect(output).to include("ZORK I: The Great Underground Empire")
        expect(output).to be_end_with(">")
      end

      it "returns all output when pattern is nil" do
        dfrotz.start
        output = dfrotz.read_until(nil)
        expect(output).to include("ZORK I: The Great Underground Empire")
      end

      it "reads up to the save prompt" do
        dfrotz.start
        dfrotz.write("save")
        output = dfrotz.read_until(/Please enter a filename \[.*\]: /)
        expect(output).to be_end_with("Please enter a filename [zork1.qzl]: ")
      end
    end

    describe "game interaction" do
      before do
        dfrotz.start
        # Clear initial output
        dfrotz.read_all
      end

      it "handles basic game commands" do
        # Test 'look' command
        dfrotz.write("look")
        output = dfrotz.read_all
        expect(output).to include("West of House")
        expect(output).to include("white house")

        # Test 'inventory' command
        dfrotz.write("inventory")
        output = dfrotz.read_all
        expect(output).to include("empty-handed")

        # Test 'xyzzy' command
        dfrotz.write("xyzzy")
        output = dfrotz.read_all
        expect(output).to include("A hollow voice says")

        # Test invalid command
        dfrotz.write("fart")
        output = dfrotz.read_all
        expect(output).to include(%(I don't know the word "fart"))

        # Move north
        dfrotz.write("north")
        output = dfrotz.read_all
        expect(output).to include("North of House")

        # Try to move south (should stay at North of House since there's no south exit)
        dfrotz.write("south")
        output = dfrotz.read_all
        expect(output).to include("North of House")

        # Test 'examine house' command
        dfrotz.write("examine house")
        output = dfrotz.read_all
        expect(output).to include("colonial house")

        # Test 'quit' command
        dfrotz.write("quit")
        output = dfrotz.read_until(/ >$/)
        expect(output).to include("Do you wish to leave the game? (Y is affirmative): ")
        dfrotz.write("y")
        output = dfrotz.read_all
        expect(output).to be_empty
        expect(dfrotz).not_to be_running
      end
    end

    describe "#terminate" do
      it "safely terminates when not running" do
        expect { dfrotz.terminate }.not_to raise_error
      end

      it "terminates running process" do
        dfrotz.start
        expect(dfrotz).to be_running
        dfrotz.terminate
        expect(dfrotz).not_to be_running
      end
    end

    describe "error handling" do
      it "handles broken pipe errors gracefully" do
        dfrotz.start
        dfrotz.terminate
        expect(dfrotz.write("look")).to be false
      end

      it "handles 'quit' command" do
        dfrotz.start
        dfrotz.write("quit")
        output = dfrotz.read_until(/ >$/)
        expect(output).to include("Do you wish to leave the game? (Y is affirmative): ")
        dfrotz.write("y")
        expect(dfrotz).not_to be_running
      end
    end
  end
end
