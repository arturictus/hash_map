require 'spec_helper'

module HashMapped
  def hash_mapped(*original)
    HashMappedMatcher.new(original)
  end

  class HashMappedMatcher
    attr_reader :key, :mapped_hash, :original_hash, :from_key, :mapped_has_key,
                :description_messages, :failure_messages

    def initialize(key)
      @key = key
      @error = []
      # @error_messages = []
      @description_messages = []
      @failure_messages = []
    end

    def matches?(hash)
      @mapped_hash = hash
      _has_key && _from
    end

    def description
      description_messages.join(', ')
    end

    def failure_message
      failure_messages.join(', ')
    end


    def from(original_hash, *from_key)
      @original_hash, @from_key = original_hash, from_key
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
        description_messages << "have key `#{key}` after been mapped"
      else
        failure_messages << "has no key `#{key}` after been mapped"
        false
      end
    end

    def _from
      return true unless original_hash
      if original_has_key?
        if original_value == mapped_value
          description_messages << "`#{key}` and original `#{from_key}` are the same"
        else
          failure_messages << "`#{key}` and original `#{from_key}` are NOT the same"
          false
        end
      else
        failure_messages << "original has no key: `#{from_key}`"
        false
      end
    end

    def _nested_keys(hash, keys)
      keys.inject({ value: hash, has_key: true }) do |out, key|
        return { value: nil, has_key: false } unless out[:value]
        return { value: nil, has_key: false } unless out[:has_key]
        { value: out[:value][key], has_key: out[:value].has_key?(key) }
      end
    end
  end
end

describe 'RspecMatchers' do
  include HashMapped

  it do
    output = { name: :hello }
    expect(output).to hash_mapped(:name)
  end
  it do
    original = { first_name: :hello }
    output = { name: :hello }
    expect(output).to hash_mapped(:name).from(original, :first_name)
  end
  it do
    original = { user: { first_name: :hello } }
    output = { name: :hello }
    expect(output).to hash_mapped(:name).from(original, :user, :first_name)
  end

  it do
    original = { user: { first_name: :hello } }
    output = { user: { name: :hello } }
    expect(output).to hash_mapped(:user, :name).from(original, :user, :first_name)
  end

  describe 'failure messages' do
    before { pending 'execute just to see error messages' }
    let(:original) { {} }
    let(:output) { {} }
    it { expect(output).to hash_mapped(:name) }
    it { expect(output).to hash_mapped(:name).from(original, :first_name) }
    it { expect(output).to hash_mapped(:name).from(original, :user, :first_name) }
    it do
      expect(output).to hash_mapped(:user, :name).from(original, :user, :first_name)
    end
  end
end
