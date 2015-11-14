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
      new_hash = {}.tap{ |h| h[:key] =  single_to_ary(key) }
      new_hash[:proc] = block if block
      new_hash[:from] = generate_from(new_hash, opts)
      attributes << new_hash.merge!(opts.except(:from))
      new_hash
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
      Array.wrap(elem)
    end
  end
end
