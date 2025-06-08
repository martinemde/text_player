# frozen_string_literal: true

require "thor"
require_relative "../text_player"

module TextPlayer
  class CLI < Thor
    default_command :play

    desc "play GAME", "Play a text adventure game"
    option :formatter, type: :string, default: "shell", desc: "Specify the formatter to use (text, data, json, shell)"
    def play(game)
      gamefile = TextPlayer::Gamefile.from_input(game)
      session = TextPlayer::Session.new(gamefile)

      formatter_type = options[:formatter].downcase.to_sym
      formatter = TextPlayer::Formatters.create(formatter_type)

      session.run do |result|
        formatter.print(result, $stdout)
        $stdin.gets.chomp
      end
    end

    def self.exit_on_failure?
      true
    end
  end
end
