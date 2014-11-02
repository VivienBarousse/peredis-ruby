module Peredis
  module Resp
    class Parser

      def initialize(input)
        @input = input
      end

      def next
        case input.read(1)
        when ':'
          next_integer
        when '+'
          next_string
        when '$'
          next_bulk_string
        when '*'
          next_array
        end
      end

      private

      def next_integer
        Integer(input.readline.strip)
      end

      def next_string
        input.readline.strip
      end

      def next_bulk_string
        length = next_integer

        # Support for null bulk strings
        return nil if length < 0

        string = input.read(length)

        # Discard the line break after the string
        input.readline

        string
      end

      def next_array
        length = next_integer

        # Support for null arrays
        return nil if length < 0

        (1..length).map do
          self.next
        end
      end

      attr_reader :input

    end
  end
end
