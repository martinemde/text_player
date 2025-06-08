# frozen_string_literal: true

require_relative "commands/action_command"
require_relative "commands/quit_command"
require_relative "commands/restore_command"
require_relative "commands/save_command"
require_relative "commands/score_command"
require_relative "commands/start_command"

module TextPlayer
  module Commands
    def self.create(input, game_name: nil)
      case input.strip.downcase
      when "score"
        ScoreCommand.new
      when /^save\s*(\S+)/ # no end anchor to catch all save commands that have args
        SaveCommand.new(save: Save.new(game_name:, slot: Regexp.last_match(1)))
      when "save"
        SaveCommand.new(save: Save.new(game_name:))
      when /^restore\s*(\S+)/ # no end anchor to catch all restore commands that have args
        RestoreCommand.new(save: Save.new(game_name:, slot: Regexp.last_match(1)))
      when "restore"
        RestoreCommand.new(save: Save.new(game_name:))
      when "quit"
        QuitCommand.new
      else
        ActionCommand.new(input:)
      end
    end
  end
end
