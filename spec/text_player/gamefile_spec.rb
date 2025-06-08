# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

RSpec.describe TextPlayer::Gamefile do
  let(:game_dir) { TextPlayer::GAME_DIR }
  let(:existing_game) { "zork1" }
  let(:existing_game_path) { game_dir.join("#{existing_game}.z5") }

  describe ".from_input" do
    context "when input contains a path separator" do
      it "creates a Gamefile from a full path" do
        path = "/path/to/game.z5"
        gamefile = described_class.from_input(path)

        expect(gamefile.name).to eq("game.z5")
        expect(gamefile.path).to eq(Pathname.new(path))
      end

      it "creates a Gamefile from a relative path" do
        path = "games/zork1.z5"
        gamefile = described_class.from_input(path)

        expect(gamefile.name).to eq("zork1.z5")
        expect(gamefile.path).to eq(Pathname.new(path))
      end
    end

    context "when input is a simple game name" do
      it "finds a unique game file" do
        gamefile = described_class.from_input(existing_game)

        expect(gamefile.name).to eq("#{existing_game}.z5")
        expect(gamefile.path).to eq(existing_game_path)
      end

      it "raises an error when multiple games match" do
        # Create temporary files to simulate multiple matches
        Dir.mktmpdir do |tmpdir|
          allow(TextPlayer).to receive(:const_get).with(:GAME_DIR).and_return(Pathname.new(tmpdir))

          File.write(File.join(tmpdir, "test.z5"), "")
          File.write(File.join(tmpdir, "test.z8"), "")

          expect {
            described_class.from_input("test")
          }.to raise_error(ArgumentError, /Multiple games found for 'test'/)
        end
      end

      it "raises an error when no games match" do
        expect {
          described_class.from_input("nonexistent")
        }.to raise_error(ArgumentError, /Multiple games found for 'nonexistent'/)
      end
    end
  end

  describe "#initialize" do
    it "converts name to string" do
      gamefile = described_class.new(name: :symbol_name, path: "/path/to/game")
      expect(gamefile.name).to eq("symbol_name")
    end

    it "converts path to Pathname" do
      gamefile = described_class.new(name: "game", path: "/path/to/game")
      expect(gamefile.path).to be_a(Pathname)
      expect(gamefile.path.to_s).to eq("/path/to/game")
    end

    it "handles Pathname input for path" do
      pathname = Pathname.new("/path/to/game")
      gamefile = described_class.new(name: "game", path: pathname)
      expect(gamefile.path).to eq(pathname)
    end
  end

  describe "#exist?" do
    it "returns true when the file exists" do
      gamefile = described_class.new(name: "#{existing_game}.z5", path: existing_game_path)
      expect(gamefile.exist?).to be true
    end

    it "returns false when the file does not exist" do
      gamefile = described_class.new(name: "nonexistent.z5", path: "/nonexistent/path")
      expect(gamefile.exist?).to be false
    end
  end

  describe "#full_path" do
    it "returns the expanded absolute path as a string" do
      gamefile = described_class.new(name: "game.z5", path: "relative/path/game.z5")
      full_path = gamefile.full_path

      expect(full_path).to be_a(String)
      expect(full_path).to start_with("/")
      expect(full_path).to end_with("relative/path/game.z5")
    end

    it "handles already absolute paths" do
      absolute_path = "/absolute/path/game.z5"
      gamefile = described_class.new(name: "game.z5", path: absolute_path)

      expect(gamefile.full_path).to eq(absolute_path)
    end
  end

  describe "Data class behavior" do
    it "is immutable" do
      gamefile = described_class.new(name: "game.z5", path: "/path/to/game.z5")

      expect { gamefile.name = "new_name" }.to raise_error(NoMethodError)
      expect { gamefile.path = "/new/path" }.to raise_error(NoMethodError)
    end

    it "supports equality comparison" do
      gamefile1 = described_class.new(name: "game.z5", path: "/path/to/game.z5")
      gamefile2 = described_class.new(name: "game.z5", path: "/path/to/game.z5")
      gamefile3 = described_class.new(name: "other.z5", path: "/path/to/other.z5")

      expect(gamefile1).to eq(gamefile2)
      expect(gamefile1).not_to eq(gamefile3)
    end

    it "supports hash operations" do
      gamefile1 = described_class.new(name: "game.z5", path: "/path/to/game.z5")
      gamefile2 = described_class.new(name: "game.z5", path: "/path/to/game.z5")

      expect(gamefile1.hash).to eq(gamefile2.hash)
    end

    it "provides to_h method" do
      gamefile = described_class.new(name: "game.z5", path: "/path/to/game.z5")
      hash = gamefile.to_h

      expect(hash).to eq({
        name: "game.z5",
        path: Pathname.new("/path/to/game.z5")
      })
    end
  end
end
