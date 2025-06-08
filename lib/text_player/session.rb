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
      @process = Dfrotz.new(GameUtils.full_path(game_filename), dfrotz:)
      @started = false
      @interrupt_count = 0
      @formatter = create_formatter(formatter)
      setup_interrupt_handling
    end

    def save_filename(slot)
      "saves/#{@game_filename.delete_suffix(".z5")}_#{slot}.qzl"
    end

    def start
      return @initial_result if @started

      @process.start

      # Read until we get a prompt, automatically timeout if we don't get one.
      raw_output = @process.read_until(PROMPT_REGEX)

      # Handle common startup prompts
      raw_output += handle_startup_prompts(raw_output)

      @started = true
      @initial_result = CommandResult.new(
        input: "",
        raw_output: raw_output,
        operation: :start,
        success: true,
        message: "Game started successfully"
      )
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
      command = Commands::SaveCommand.new(input:, slot: slot || TextPlayer::AUTO_SAVE_SLOT,
        game_filename: game_filename)
      execute_command(command)
    end

    def restore(slot = nil)
      command = Commands::RestoreCommand.new(input:, slot: slot || TextPlayer::AUTO_SAVE_SLOT,
        game_filename: game_filename)
      execute_command(command)
    end

    def quit
      command = Commands::QuitCommand.new
      execute_command(command)
    end

    def running?
      @started && @process.running?
    end

    private

    def execute_command(command)
      command_result = command.execute(@process)
      @formatter.format_command_result(command_result)
    end

    def create_command_result(cmd)
      return create_error_result(cmd, "Game not started") unless @started

      case cmd.strip.downcase
      when "save" then save
      when "restore" then restore
      when /^restore\s*(\S+)$/ then restore(::Regexp.last_match(1))
      when "quit" then quit
      else
        execute_game_command(cmd)
      end
    end

    def execute_game_command(cmd)
      @process.write(cmd)
      raw_output = @process.read_all

      CommandResult.new(
        input: cmd,
        raw_output: raw_output,
        operation: :game,
        success: true
      )
    end

    def create_error_result(input, message)
      CommandResult.new(
        input: input,
        operation: :error,
        success: false,
        message: message
      )
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
          puts "\nForce exit!"
          exit(1)
        end
      end
    end

    def create_formatter(type)
      case type
      when :data then Formatters::DataFormatter.new
      when :json then Formatters::JsonFormatter.new
      when :shell then Formatters::ShellFormatter.new
      else
        raise ArgumentError, "Unknown formatter type: #{type}. Use :data, :json, or :shell"
      end
    end

    def handle_startup_prompts(initial_output)
      output = +""

      # Handle "Press any key" prompts - be more specific
      if /(Press|Hit|More)\s+/i.match?(initial_output)
        @process.write(" ")
        output += @process.read_until(PROMPT_REGEX)
      end

      # Skip introduction if offered
      if initial_output.include?("introduction")
        @process.write("no")
        output += @process.read_until(PROMPT_REGEX)
      end

      output
    end
  end
end
