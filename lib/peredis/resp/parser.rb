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
        end
      end

      private

      def next_string
        input.readline.strip
      end

      attr_reader :input

    end
  end
end
