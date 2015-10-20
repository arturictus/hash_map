module HashMap
  module ToDSL
    extend ActiveSupport::Concern
    class_methods do
      def method_missing(method, *args, &block)
        if dsl.respond_to?(method)
          dsl.send(method, *args, &block)
        else
          super
        end
      end

      def dsl
        @dsl ||= DSL.new
      end

      def attributes
        dsl.attributes
      end
    end
  end

  class DSL
    attr_reader :attributes

    def initialize
      @attributes = []
    end

    def attributes
      @attributes
    end

    def property(key, opts = {}, &block)
      new = {}.tap{ |h| h[:key] =  single_to_ary(key) }
      new[:proc] = block if block
      new[:from] = generate_from(new, opts)
      attributes << new.merge!(opts.except(:from))
      new
    end

    def from_children(key, opts = {}, &block)
      flat = _nested(key, opts, &block)
      flat.each { |attr| attr[:from].unshift(key) }
      @attributes += flat
    end

    def to_children(key, opts = {}, &block)
      flat = _nested(key, opts, &block)
      flat.each { |attr| attr[:key].unshift(key) }
      @attributes += flat
    end

    private

    def generate_from(hash, opts)
      from = opts[:from]
      from ? single_to_ary(from) : hash[:key].dup
    end

    def _nested(key, opts = {}, &block)
      klass = self.class.new
      klass.instance_exec(&block)
      klass.attributes.flatten
    end

    def single_to_ary(elem)
      return if elem.nil?
      elem.is_a?(Array) ? elem : [elem]
    end
  end
end
