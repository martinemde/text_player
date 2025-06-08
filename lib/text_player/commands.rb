# frozen_string_literal: true

require_relative "commands/action_command"
require_relative "commands/quit_command"
require_relative "commands/restore_command"
require_relative "commands/save_command"
require_relative "commands/score_command"

module TextPlayer
  module Commands
    def self.create(input, game_filename: nil)
      case input.strip.downcase
      when "score"
        ScoreCommand.new
      when /^save\s*(\S+)/ # no end anchor to catch all save commands that have args
        SaveCommand.new(save: Save.new(game_filename:, slot: Regexp.last_match(1)))
      when "save"
        SaveCommand.new(save: Save.new(game_filename:))
      when /^restore\s*(\S+)/ # no end anchor to catch all restore commands that have args
        RestoreCommand.new(save: Save.new(game_filename:, slot: Regexp.last_match(1)))
      when "restore"
        RestoreCommand.new(save: Save.new(game_filename:))
      when "quit"
        QuitCommand.new
      else
        ActionCommand.new(input:)
      end
    end
  end
end
