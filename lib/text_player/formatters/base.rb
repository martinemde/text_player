# frozen_string_literal: true

require_relative "../command_result"

module TextPlayer
  module Formatters
    # Base formatter with stream writing and common interface
    class Base
      def self.write(command_result, stream)
        new(command_result).write(stream)
      end

      attr_reader :command_result

      def initialize(command_result)
        @command_result = command_result
      end

      # Write formatted output to stream
      def write(stream)
        stream.write(to_s)
      end

      # String representation for stream output
      def to_s
        command_result.to_h.inspect
      end

      # Hash representation for programmatic access
      def to_h
        command_result.to_h
      end
    end
  end
end
