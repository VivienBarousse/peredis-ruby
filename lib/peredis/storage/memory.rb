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

      def ping
        "pong"
      end

      def exists(key)
        @keys.has_key?(key) ? 1 : 0
      end

      def del(*keys)
        keys.count do |key|
          !!@keys.delete(key)
        end
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

      def mset(*args)
        raise ArgumentError unless args.length % 2 == 0

        (0..args.length - 1).step(2).each do |i|
          set(args[i], args[i+1])
        end
        1
      end

      # -
      # Integers
      # -

      def incr(key)
        value = Integer(get(key) || 0)
        new_value = value + 1
        set(key, new_value.to_s)
        new_value
      end

      # -
      # Sets
      # -

      def sadd(key, *values)
        values.each do |value|
          find_set(key, true) << value
        end
      end

      def smembers(key)
        find_set(key).dup
      end

      def sismember(key, value)
        set = find_set(key)
        set && set.include?(value)
      end

      def scard(key)
        find_set(key).count
      end

      # -
      # Lists
      # -

      def lpush(key, value)
        list = find_list(key, true)
        list.insert(0, value)
        return list.size
      end

      def rpush(key, value)
        list = find_list(key, true)
        list << value
        return list.size
      end

      def lindex(key, index)
        list = find_list(key, false)
        return list[index]
      end

      def lpop(key)
        list = find_list(key, false)
        value = list && list.shift
        return value
      end

      private

      def find_set(key, create = false)
        find_key_of_type(key, Set, create)
      end

      def find_list(key, create = false)
        find_key_of_type(key, Array, create)
      end

      def find_key_of_type(key, klass, create = false)
        value = @keys[key] || klass.new
        if create && !@keys.has_key?(key)
          @keys[key] = value
        end

        raise "Unexpected key type" unless value.is_a?(klass)
        value
      end

    end
  end
end
