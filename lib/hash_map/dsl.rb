module HashMap
  module ToDSL
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

    def _set_attributes_from_inheritance(attrs)
      dsl._set_attributes(attrs.dup)
    end
  end

  class DSL
    class NoMapperForCollection < StandardError; end
    class InvalidOptionsForProperty < StandardError; end
    attr_reader :attributes

    def initialize
      @attributes = []
    end

    def after_each(*middlewares)
      @after_each ||= []
      @after_each += middlewares
    end

    def transforms_output(*middlewares)
      @transform_output ||= []
      @transform_output += middlewares
    end

    def transforms_input(*middlewares)
      @transform_input ||= []
      @transform_input += middlewares
    end

    def only_provided_keys
      @transform_output ||= []
      @transform_output << RemoveUnprovideds
      @after_each ||= []
      @after_each << MarkUnprovided
    end

    def _set_attributes(attrs)
      @attributes = attrs
    end

    def property(key, opts = {}, &block)
      fail InvalidOptionsForProperty, "[HashMap Error] using: `#{__callee__}` with wrong options, second argument must be a `Hash" unless opts.is_a? Hash
      new_hash = {}.tap { |h| h[:key] = single_to_ary(key) }
      new_hash[:proc] = block if block
      new_hash[:from] = generate_from(new_hash, opts)
      attributes << new_hash.merge!(Fusu::Hash.except(opts, :from))
      new_hash
    end

    def collection(key, opts = {}, &block)
      unless opts[:mapper]
        fail NoMapperForCollection, "[HashMap Error] Called 'collection' without the ':mapper' option"
      end
      opts.merge!(is_collection: true)
      property(key, opts, &block)
    end

    def properties(*args)
      args.each do |arg|
        property(*arg)
      end
    end

    def from_children(key, opts = {}, &block)
      puts "[HashMap Deprecation Warning] using: #{__callee__} use from_child instead"
      from_child(key, opts, &block)
    end

    def from_child(*args, &block)
      options = args.last.is_a?(::Hash) ? args.pop : {}
      key = args
      flat = _nested(key, options, &block)
      keys = Fusu::Array.wrap(key)
      flat.each do |attr|
        keys.reverse.each do |k|
          attr[:from].unshift(k)
          attr[:from_child] ? attr[:from_child].unshift(k) : attr[:from_child] = [k]
        end
      end
      @attributes += flat
    end

    def to_children(key, opts = {}, &block)
      puts "[HashMap Deprecation Warning] using: #{__callee__} use to_child instead"
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
      Fusu::Array.wrap(elem)
    end
  end
end
