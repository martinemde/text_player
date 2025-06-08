# frozen_string_literal: true

require "open3"
require "timeout"
require "pathname"

module TextPlayer
  # Dfrotz - Direct interface to dfrotz interpreter
  class Dfrotz
    TIMEOUT = 1
    IO_SELECT_TIMEOUT = 0.1
    CHUNK_SIZE = 1024
    COMMAND_DELAY = 0.1
    SYSTEM_PATH = "dfrotz"

    def self.path
      ENV.fetch("DFROTZ_PATH", SYSTEM_PATH)
    end

    def self.executable?(path = self.path)
      File.executable?(path) || system("which #{path} > /dev/null 2>&1")
    end

    def initialize(game_path, dfrotz: nil, timeout: TIMEOUT, command_delay: COMMAND_DELAY)
      Signal.trap("PIPE", "DEFAULT")
      @game_path = game_path
      @dfrotz = dfrotz || self.class.path
      raise "dfrotz not found: #{@dfrotz.inspect}" unless self.class.executable?(@dfrotz)

      @timeout = timeout
      @command_delay = command_delay
      @stdin = @stdout = @wait_thr = nil
    end

    def start
      return true if running?

      @stdin, @stdout, @wait_thr = Open3.popen2(@dfrotz, @game_path)
      true
    end

    # Send a command to the game.
    #
    # Automatically sleeps for COMMAND_DELAY seconds, keeping callers simple.
    # It takes time for every command to return output. If you don't wait,
    # you'll get nothing in response, and then follow up commands will
    # return the last command's output instead of the current command's.
    def write(cmd)
      return false unless running?

      @stdin.puts(cmd)
      @stdin.flush
      sleep(@command_delay)
      true
    rescue Errno::EPIPE
      # Process has exited - this is expected during quit
      false
    end

    def read_all
      read_until(nil)
    end

    def read_until(pattern)
      return "" unless running?

      output = +""
      begin
        Timeout.timeout(@timeout) do
          loop do
            break unless read_chunk_into(output)
            break if pattern && output =~ pattern
          end
        end
      rescue Timeout::Error
        # Return whatever we got
      end
      output
    end

    def running?
      @stdin && !@stdin.closed? && @wait_thr&.alive?
    end

    def terminate
      return true unless running?

      close
      @wait_thr.kill
    rescue
      true
    end

    private

    def read_chunk_into(output)
      return false unless IO.select([@stdout], nil, nil, IO_SELECT_TIMEOUT)

      chunk = @stdout.read_nonblock(CHUNK_SIZE)
      output << chunk
      true
    rescue IO::WaitReadable, EOFError
      false
    end

    def close
      @stdin&.close
      @stdout&.close
    rescue
      true
    end
  end
end
