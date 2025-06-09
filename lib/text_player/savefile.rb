# frozen_string_literal: true

module TextPlayer
  # Utilities for saving and restoring game state
  Savefile = Data.define(:game_name, :slot) do
    def initialize(game_name: nil, slot: nil)
      slot = slot.to_s.strip
      slot = TextPlayer::AUTO_SAVE_SLOT if slot.empty?
      super
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
