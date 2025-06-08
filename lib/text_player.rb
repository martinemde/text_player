# frozen_string_literal: true

# Agent Carmen - Session with UI Formatter System
#
# This system provides different output formatters for various UI needs:
#
# 1. DataFormatter (:data) - Returns structured hash with:
#    Game Output: { type: 'game_output', location: "Room Name", score: 0, moves: 1,
#                   output: "clean text", has_prompt: true }
#    Feedback: { type: 'feedback', operation: 'save', success: true,
#                message: "Game saved successfully", slot: "autosave", ... }
#
# 2. JsonFormatter (:json) - Returns JSON string of DataFormatter output
#
# 3. ShellFormatter (:shell) - Returns formatted text ready for interactive shell:
#    Game Output: Full text with prompt (adds ">" if missing)
#    Feedback: Colored status with ✓/✗ indicators and details
#    Provides prompt_for_command method for user input
#
# Usage:
#   # Data formatter for structured access
#   game = Session.new('zork1.z5', formatter: :data)
#   result = game.start
#   puts result[:location]  # "West of House"
#   puts result[:score]     # 0
#
#   save_result = game.call('save')
#   puts save_result[:success]  # true/false
#   puts save_result[:slot]     # "autosave"
#
#   # Shell formatter for interactive use
#   shell_game = Session.new('zork1.z5', formatter: :shell)
#   output = shell_game.start  # Full text with prompt
#   command = shell_game.formatter.prompt_for_command

require_relative "text_player/version"
require_relative "text_player/game_utils"
require_relative "text_player/dfrotz"
require_relative "text_player/formatters"
require_relative "text_player/commands"
require_relative "text_player/session"

module TextPlayer
  class Error < StandardError; end

  # Common constants used across the library
  SCORE_REGEX = /[0-9]+ \(total [points ]*[out ]*of [a mxiuof]*[a posible]*[0-9]+/i
  PROMPT_REGEX = /^>\s*$/
  AUTO_SAVE_SLOT = "autosave"
  FILENAME_PROMPT_REGEX = /Please enter a filename \[.*\]: /
end
