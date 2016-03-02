module HashMap
  class Base
    class << self
      def property(key, opts = {}, &block); dsl.send(__callee__, key, opts, &block); end
      def properties(*args); dsl.send(__callee__, *args); end
      def from_child(key, opts = {}, &block); dsl.send(__callee__, key, opts, &block); end
      def to_child(key, opts = {}, &block); dsl.send(__callee__, key, opts, &block); end
      def collection(key, opts = {}, &block); dsl.send(__callee__, key, opts, &block); end
      def from_children(key, opts = {}, &block); dsl.send(__callee__, key, opts, &block); end

      def dsl
        @dsl ||= DSL.new
      end

      def attributes
        dsl.attributes
      end
    end
    attr_reader :original
    def initialize(original)
      @original = original
    end
    delegate :[], to: :output

    def self.map(input)
      new(input).output
    end
    singleton_class.send(:alias_method, :call, :map)

    def mapper
      @mapper ||= Mapper.new(original, self)
    end

    def output
      @output ||= mapper.output
    end
    alias_method :to_h, :output
    alias_method :to_hash, :output
  end
end
