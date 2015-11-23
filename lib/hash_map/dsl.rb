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

    # def attributes
    #   @attributes
    # end

    def property(key, opts = {}, &block)
      new_hash = {}.tap { |h| h[:key] = single_to_ary(key) }
      new_hash[:proc] = block if block
      new_hash[:from] = generate_from(new_hash, opts)
      attributes << new_hash.merge!(opts.except(:from))
      new_hash
    end

    def properties(*args)
      args.each do |arg|
        property(*arg)
      end
    end

    def from_children(key, opts = {}, &block)
      puts "[Depercation Warning] using: #{__callee__} use from_child instead"
      from_child(key, opts, &block)
    end

    def from_child(key, opts = {}, &block)
      flat = _nested(key, opts, &block)
      flat.each do |attr|
        attr[:from].unshift(key)
        attr[:from_child] ? attr[:from_child].unshift(key) : attr[:from_child] = [key]
      end
      @attributes += flat
    end

    def to_children(key, opts = {}, &block)
      puts "[Depercation Warning] using: #{__callee__} use to_child instead"
      to_child(key, opts, &block)
    end

    def to_child(key, opts = {}, &block)
      flat = _nested(key, opts, &block)
      flat.each { |attr| attr[:key].unshift(key) }
      @attributes += flat
    end

    private

    def generate_from(hash, opts)
      from = opts[:from]
      from ? single_to_ary(from) : hash[:key].dup
    end

    def _nested(_key, _opts = {}, &block)
      klass = self.class.new
      klass.instance_exec(&block)
      klass.attributes.flatten
    end

    def single_to_ary(elem)
      Array.wrap(elem)
    end
  end
end
