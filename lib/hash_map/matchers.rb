module HashMap
  module Matchers
    def hash_mapped(*original)
      HashMappedMatcher.new(original)
    end

    class HashMappedMatcher
      attr_reader :key, :mapped_hash, :original_hash, :from_key, :mapped_has_key,
                  :description_messages, :failure_messages, :expected, :expected_provided

      def initialize(key)
        @key = key
        @error = []
        @description_messages = []
        @failure_messages = []
      end

      def matches?(hash)
        @mapped_hash = hash
        _has_key && _from && equality
      end

      def description
        description_messages.join(', ')
      end

      def failure_message
        failure_messages.join(', ')
      end

      def from(original_hash, *from_key)
        @original_hash = original_hash
        @from_key = from_key
        self
      end

      def and_eq(expected)
        @expected_provided = true
        @expected = expected
        self
      end

      private

      def mapped_has_key?
        mapped_results[:has_key]
      end

      def mapped_value
        mapped_results[:value]
      end

      def original_has_key?
        original_results[:has_key]
      end

      def original_value
        original_results[:value]
      end

      def mapped_results
        @mapped_results ||= _nested_keys(mapped_hash, key)
      end

      def original_results
        @original_results ||= _nested_keys(original_hash, from_key)
      end

      def _has_key
        if mapped_has_key?
          description_messages << "have key #{key_to_message} after been mapped"
        else
          failure_messages << "has no key #{key_to_message} after been mapped"
          false
        end
      end

      def _from
        return true unless original_hash
        if original_has_key?
          if original_value == mapped_value
            description_messages << "#{key_to_message} and original #{from_key_to_message} are the same"
          else
            failure_messages << "#{key_to_message} and original #{from_key_to_message} are NOT the same"
            false
          end
        else
          failure_messages << "original has no key: #{from_key_to_message}"
          false
        end
      end

      def from_key_to_message
        keys_to_message from_key
      end

      def key_to_message
        keys_to_message key
      end

      def keys_to_message(keys)
        children = keys.map { |k| key_representation(k) }.join(' -> ')
        "`#{children}`"
      end

      def key_representation(k)
        k.is_a?(Symbol) ? ":#{k}" : "'#{k}'"
      end

      def equality
        return true unless expected_provided
        if mapped_value == expected
          description_messages << "and eq `#{expected}`"
        else
          failure_messages << "key #{key_to_message} expected to eq `#{expected}`"
          false
        end
      end

      def _nested_keys(hash, keys)
        keys.inject({ value: hash, has_key: true }) do |out, key|
          return { value: nil, has_key: false } unless out[:value]
          return { value: nil, has_key: false } unless out[:has_key]
          { value: out[:value][key], has_key: out[:value].key?(key) }
        end
      end
    end
  end
end
