# frozen_string_literal: true

require "pathname"

module TextPlayer
  # GameUtils - Utility methods for game file operations
  module GameUtils
    GAME_DIR = Pathname.new(__dir__).join("../../games").expand_path

    module_function

    def valid_game?(name) = name && GAME_DIR.join(name).exist?

    def full_path(name) = GAME_DIR.join(name).expand_path.to_s
  end
end
