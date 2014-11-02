module Peredis
  module Resp
    class Serializer

      END_OF_LINE = "\r\n"

      def initialize(output)
        @output = output
      end

      def write(object)
        case object
        when String
          write_string(object)
        end
      end

      private

      attr_reader :output

      def write_string(string)
        output << '$'
        output << string.length.to_s
        output << END_OF_LINE
        output << string
        output << END_OF_LINE
      end

    end
  end
end
