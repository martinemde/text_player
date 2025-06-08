# frozen_string_literal: true

require_relative "game_utils"
require_relative "dfrotz"
require_relative "formatters"
require_relative "command_result"

module TextPlayer
  # Mid-level: Manages game session lifecycle and output formatting
  class Session
    SCORE_REGEX = /[0-9]+ \(total [points ]*[out ]*of [a mxiuof]*[a posible]*[0-9]+/i
    PROMPT_REGEX = /^>\s*$/
    AUTO_SAVE_SLOT = "autosave"
    FILENAME_PROMPT_REGEX = /Please enter a filename \[.*\]: /

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
    def execute_command(cmd)
      command_result = create_command_result(cmd)
      @formatter.format_command_result(command_result)
    end

    def get_score
      return nil unless @started

      @process.write("score")
      output = @process.read_until(PROMPT_REGEX)

      @formatter.format_score(output)
    end

    def save(slot = nil)
      return create_error_result("save", "Game not started") unless @started

      slot ||= AUTO_SAVE_SLOT

      @process.write("save")
      @process.read_until(FILENAME_PROMPT_REGEX)
      @process.write(save_filename(slot))

      result = @process.read_until(/Overwrite existing file\? |Ok\.|Failed\.|>/i)

      if result.include?("Overwrite existing file?")
        @process.write("y")
        result += @process.read_until(/Ok\.|Failed\.|>/i)
      end

      success = result.include?("Ok.")
      message = if success
        "Game saved successfully"
      elsif result.include?("Failed.")
        "Save operation failed"
      else
        "Save completed"
      end

      CommandResult.new(
        input: "save",
        raw_output: result,
        operation: :save,
        success: success,
        message: message,
        slot: slot,
        filename: save_filename(slot)
      )
    end

    def restore(slot = nil)
      return create_error_result("restore", "Game not started") unless @started

      slot ||= AUTO_SAVE_SLOT

      @process.write("restore")
      @process.read_until(FILENAME_PROMPT_REGEX)
      @process.write(save_filename(slot))

      result = @process.read_until(/Ok\.|Failed\.|not found|>/i)

      success = result.include?("Ok.")
      message = if success
        "Game restored successfully"
      elsif result.include?("Failed") || result.include?("not found")
        "Restore failed - file not found or corrupted"
      else
        "Restore operation completed"
      end

      CommandResult.new(
        input: "restore",
        raw_output: result,
        operation: :restore,
        success: success,
        message: message,
        slot: slot,
        filename: save_filename(slot)
      )
    end

    def quit
      return create_error_result("quit", "Game not started") unless @started

      save

      score = get_score
      puts @formatter.format_score(score)

      begin
        @process.write("quit")
        # Give the game a moment to process quit and ask for confirmation
        sleep(0.2)
        # Send 'y' to confirm quit
        @process.write("y")
      rescue Errno::EPIPE
        # Expected when process exits - ignore
      end

      @process.terminate
      @started = false

      CommandResult.new(
        input: "quit",
        operation: :quit,
        success: true,
        message: "Game quit successfully"
      )
    end

    def running?
      @started && @process.running?
    end

    private

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
