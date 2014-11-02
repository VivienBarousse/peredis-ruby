module Peredis
  module Resp
    class Parser

      def initialize(input)
        @input = input
      end

      def next
        case input.read(1)
        when '+'
          next_string
        when '$'
          next_bulk_string
        end
      end

      private

      def next_string
        input.readline.strip
      end

      def next_bulk_string
        length = Integer(input.readline.strip)

        # Support for null bulk strings
        if length < 0
          return nil
        end

        string = input.read(length)

        # Discard the line break after the string
        input.readline

        string
      end

      attr_reader :input

    end
  end
end
