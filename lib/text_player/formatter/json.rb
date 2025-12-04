# frozen_string_literal: true

require "json"

module TextPlayer
  module Formatter
    # JSON formatter - returns JSON string of structured data
    module Json
      extend self

      def format(command_result)
        parsed = OutputParser.parse(command_result.raw_output)

        data = {
          input: command_result.input,
          operation: command_result.operation.to_s,
          success: command_result.success?,
          raw_output: command_result.raw_output,
        }.merge(parsed)

        # Add optional command_result fields if present
        data[:message] = command_result.message if command_result.message
        data[:filename] = command_result.filename if command_result.respond_to?(:filename) && command_result.filename

        ::JSON.generate(data)
      end
    end
  end
end

