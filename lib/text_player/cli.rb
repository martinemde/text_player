# frozen_string_literal: true

require "thor"
require_relative "../text_player"

module TextPlayer
  class CLI < Thor
    default_command :play

    desc "play GAME", "Play a text adventure game"
    option :formatter, type: :string, default: "shell", desc: "Specify the formatter to use (text, json, shell)"
    def play(game)
      gamefile = TextPlayer::Gamefile.from_input(game)
      session = TextPlayer::Session.new(gamefile)

      formatter_type = options[:formatter].downcase.to_sym
      formatter = TextPlayer::Formatter.by_name(formatter_type)

      session.run do |result|
        $stdout.write formatter.format(result)
        $stdin.gets
      end
    end

    def self.exit_on_failure?
      true
    end
  end
end
