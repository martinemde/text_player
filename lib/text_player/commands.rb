# frozen_string_literal: true

require_relative "commands/action"
require_relative "commands/quit"
require_relative "commands/restore"
require_relative "commands/save"
require_relative "commands/score"
require_relative "commands/start"

module TextPlayer
  module Commands
    def self.create(input, game_name: nil)
      case input.strip.downcase
      when "score"
        Commands::Score.new
      when /^save\s*(\S+)/ # no end anchor to catch all save commands that have args
        Commands::Save.new(savefile: Savefile.new(game_name:, slot: Regexp.last_match(1)))
      when "save"
        Commands::Save.new(savefile: Savefile.new(game_name:))
      when /^restore\s*(\S+)/ # no end anchor to catch all restore commands that have args
        Commands::Restore.new(savefile: Savefile.new(game_name:, slot: Regexp.last_match(1)))
      when "restore"
        Commands::Restore.new(savefile: Savefile.new(game_name:))
      when "quit"
        Commands::Quit.new
      else
        Commands::Action.new(input:)
      end
    end
  end
end
