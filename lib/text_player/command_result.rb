# frozen_string_literal: true

module TextPlayer
  # Encapsulates the result of executing a command
  CommandResult = Data.define(:input, :raw_output, :operation, :success, :message, :details) do
    # Common failure patterns in text adventure games

    def initialize(input:, raw_output: "", operation: :action, success: true, message: nil, **details)
      super(input:, raw_output:, operation:, success:, message:, details:)
    end

    def action? = operation == :action

    def system_command? = !action?

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
