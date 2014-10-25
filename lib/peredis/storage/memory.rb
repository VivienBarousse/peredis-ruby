require 'set'

module Peredis
  module Storage
    class Memory < Storage::Base

      def initialize(config)
        @keys = {}
      end

      # -
      # Generic
      # -

      def exists(key)
        @keys.has_key?(key)
      end

      # -
      # Strings
      # -

      def get(key)
        value = @keys[key]
        return nil unless value

        raise "Unexpected key type" unless value.is_a?(String)
        value
      end

      def set(key, value)
        @keys[key] = value
      end

      # -
      # Sets
      # -

      def sadd(key, value)
        find_set(key, true) << value
      end

      def smembers(key)
        find_set(key).dup
      end

      private

      def find_set(key, create = false)
        value = @keys[key] || Set.new
        if create && !@keys.has_key?(key)
          @keys[key] = value
        end

        raise "Unexpected key type" unless value.is_a?(Set)
        value
      end

    end
  end
end
