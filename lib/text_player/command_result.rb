# frozen_string_literal: true

module TextPlayer
  # Encapsulates the result of executing a command
  CommandResult = Data.define(:input, :raw_output, :operation, :success, :message, :details) do
    def initialize(input:, raw_output: "", operation: :game, success: true, message: nil, **details)
      super(input:, raw_output:, operation:, success:, message:, details:)
    end

    def game_command?
      operation == :game
    end

    def system_command?
      !game_command?
    end

    def success?
      success
    end

    def failure?
      !success
    end

    private

    def respond_to_missing?(method, include_private = false)
      details.key?(method) || super
    end

    def method_missing(method, *args, &block)
      if details.key?(method)
        details[method]
      else
        super
      end
    end
  end
end
