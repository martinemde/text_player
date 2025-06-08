# frozen_string_literal: true

require "pathname"

module TextPlayer
  # Gamefile - A game file and its name
  Gamefile = Data.define(:name, :path) do
    def self.from_input(input)
      if input.include?("/")
        path = Pathname.new(input)
        new(name: path.basename.to_s, path:)
      else # must be a simple game name
        matches = TextPlayer::GAME_DIR.glob("#{input}.*")

        if matches.size == 1
          path = matches.first
          new(name: path.basename.to_s, path:)
        else
          names = matches.map { |m| m.basename }
          raise ArgumentError, "Multiple games found for '#{input}':\n#{names.join("\n")}"
        end
      end
    end

    def initialize(name:, path:)
      super(name: name.to_s, path: Pathname.new(path))
    end

    def exist? = path.exist?

    def full_path = path.expand_path.to_s
  end
end
