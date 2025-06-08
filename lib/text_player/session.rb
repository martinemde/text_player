# frozen_string_literal: true

require_relative "game_utils"
require_relative "dfrotz"
require_relative "formatters"
require_relative "command_result"

module TextPlayer
  # Mid-level: Manages game session lifecycle and output formatting
  class Session
    attr_reader :formatter

    def initialize(game_filename, formatter: :shell, dfrotz: nil)
      raise ArgumentError, "Game file '#{game_filename}' not found" unless GameUtils.valid_game?(game_filename)

      @game_filename = game_filename
      @game = Dfrotz.new(GameUtils.full_path(game_filename), dfrotz:)
      @started = false
      @interrupt_count = 0
      @formatter = Formatters.create(formatter)
    end

    def start
      return @start_result if @started

      setup_interrupt_handling
      @game.start

      start_command = Commands::StartCommand.new
      @start_result = execute_command(start_command)
    end

    # We intentionally intercept certain commands.
    # Because the intention of this library is automated play, allowing an agent
    # to save to any file path on the system is a security risk at worst, and
    # a nuisance at best.
    #
    # We also only allow 1 save slot, but we automatically save to "autosave"
    # when the game is quit.
    #
    # Quit is also intercepted to make sure we shut down the game cleanly.
    def call(cmd)
      command = Commands.create(cmd, game_filename: @game_filename)
      execute_command(command)
    end

    def score
      command = Commands::ScoreCommand.new(input:)
      execute_command(command)
    end

    def save(slot = nil)
      command = Commands::SaveCommand.new(save: Save.new(game_filename:, slot:))
      execute_command(command)
    end

    def restore(slot = nil)
      command = Commands::RestoreCommand.new(save: Save.new(game_filename:, slot:))
      execute_command(command)
    end

    def quit
      command = Commands::QuitCommand.new
      execute_command(command)
    end

    def running?
      @started && @game.running?
    end

    private

    def execute_command(command)
      unless running?
        return CommandResult.new(
          input: command.input,
          operation: :error,
          success: false,
          message: "Game not running"
        )
      end

      command_result = command.execute(@game)
      @formatter.format_command_result(command_result)
    end

    def setup_interrupt_handling
      Signal.trap("INT") do
        @interrupt_count += 1
        if @interrupt_count == 1
          puts "\n\nInterrupt received - quitting game gracefully..."
          quit if running?
          puts "Game quit. Press Ctrl+C again to exit immediately."
          exit(0)
        else
          @game.terminate
          exit(1)
        end
      end
    end
  end
end
