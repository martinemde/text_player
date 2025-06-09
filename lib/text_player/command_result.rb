# frozen_string_literal: true

module TextPlayer
  # Encapsulates the result of executing a command
  CommandResult = Data.define(:input, :raw_output, :operation, :success, :message, :details) do
    # Common failure patterns in text adventure games

    def initialize(input:, raw_output: "", operation: :game, success: true, message: nil, **details)
      super(input:, raw_output:, operation:, success:, message:, details:)
    end

    # Factory method that auto-detects success/failure for game commands
    def self.from_game_output(input:, raw_output:, operation: :game, **details)
      new(
        input: input,
        raw_output: raw_output,
        operation: operation,
        success: !failure_detected?(raw_output),
        **details
      )
    end

    def self.failure_detected?(output)
      TextPlayer::FAILURE_PATTERNS.any? { |pattern| output.match?(pattern) }
    end

    def game_command? = operation == :game

    def system_command? = !game_command?

    def success? = success

    def failure? = !success

    def to_h
      super.merge(details)
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
