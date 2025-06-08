# frozen_string_literal: true

module TextPlayer
  # Utilities for saving and restoring game state
  Save = Data.define(:game_filename, :slot) do
    def initialize(game_filename: nil, slot: nil)
      slot = slot.to_s.strip
      slot = TextPlayer::AUTO_SAVE_SLOT if slot.empty?
      super
    end

    def game_name
      game_filename&.delete_suffix(".z5")
    end

    def filename
      basename = [game_name, slot].compact.join("_")
      "saves/#{basename}.qzl"
    end

    def exist?
      File.exist?(filename)
    end

    def delete
      File.delete(filename)
    end
  end
end
