# frozen_string_literal: true

require "pathname"

require_relative "text_player/version"
require_relative "text_player/gamefile"
require_relative "text_player/dfrotz"
require_relative "text_player/formatter"
require_relative "text_player/output_parser"
require_relative "text_player/commands"
require_relative "text_player/savefile"
require_relative "text_player/session"

module TextPlayer
  class Error < StandardError; end

  AUTO_SAVE_SLOT = "autosave"
  FILENAME_PROMPT_REGEX = /Please enter a filename \[.*\]: /
  PROMPT_REGEX = /^(?:\[.*\])?>\s*$/
  MORE_PROMPT_REGEX = /^\*\*\*MORE\*\*\*$/
  SCORE_REGEX = /([0-9]+) ?(?:\(total [points ]*[out ]*of [a mxiuof]*[a posible]*([0-9]+)\))?/i
  GAME_DIR = Pathname.new(__dir__).join("../games")
  FAILURE_PATTERNS = [
    /I don't understand/i,
    /I don't know/i,
    /You can't/i,
    /You're not/i,
    /I can't see/i,
    /That doesn't make sense/i,
    /That's not a verb I recognize/i,
    /What do you want to/i,
    /You don't see/i,
    /There is no/i,
    /I don't see/i,
    /I beg your pardon/i
  ].freeze
end
