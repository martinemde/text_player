# frozen_string_literal: true

module TextPlayer
  # Mid-level: Manages game session lifecycle and output formatting
  class Session
    # @param gamefile [Gamefile] The game file to play
    # @param dfrotz [Dfrotz] The dfrotz instance to use
    def initialize(gamefile, dfrotz: nil)
      @gamefile = gamefile
      @game = Dfrotz.new(gamefile.full_path, dfrotz:)
      @started = false
      @interrupt_count = 0
    end

    def run(&)
      result = start
      while running?
        command = yield result
        break if command.nil?

        result = call(command)
      end
    end

    def start
      return @start_result if @started

      setup_interrupt_handling
      @game.start
      @started = true

      start_command = Commands::Start.new
      @start_result = execute_command(start_command)
    end

    def running?
      @started && @game.running?
    end

    # We intentionally intercept certain commands.
    # Because the intention of this library is automated play, allowing an agent
    # to save to any file path on the system is a security risk at worst, and
    # a nuisance at best.
    #
    # We automatically save to "autosave" when the game is quit.
    #
    # Quit is also intercepted to make sure we shut down the game cleanly.
    def call(cmd)
      command = Commands.create(cmd, game_name: @gamefile.name)
      execute_command(command)
    end

    def score
      command = Commands::Score.new
      execute_command(command)
    end

    def save(slot = nil)
      command = Commands::Save.new(save: Save.new(game_name: @gamefile.name, slot:))
      execute_command(command)
    end

    def restore(slot = nil)
      command = Commands::Restore.new(save: Save.new(game_name: @gamefile.name, slot:))
      execute_command(command)
    end

    def quit
      command = Commands::Quit.new
      execute_command(command)
    end

    private

    def execute_command(command)
      if running?
        command.execute(@game)
      else
        CommandResult.new(
          input: command.input,
          operation: :error,
          success: false,
          message: "Game not running"
        )
      end
    end

    def setup_interrupt_handling
      Signal.trap("INT") do
        @interrupt_count += 1
        if @interrupt_count == 1
          warn "\n\nInterrupt received - quitting game gracefully..."
          quit if running?

          exit(0)
        else
          @game.terminate
          exit(1)
        end
      end
    end
  end
end
