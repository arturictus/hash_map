module HashMap
  class Base

    def self.map(*args)
      new(*args).output
    end
    singleton_class.send(:alias_method, :call, :map)

    def self.inherited(subclass)
      subclass.extend ToDSL
      return unless self < HashMap::Base
      unless dsl.attributes.empty?
        subclass._set_attributes_from_inheritance(attributes)
      end
    end

    attr_reader :original, :options
    def initialize(original, options = {})
      @original = _transforms_input(prepare_input(original))
      @options = options
    end

    def mapper
      @mapper ||= Mapper.new(original, self)
    end

    def output
      @output ||= _transforms_output(mapper.output)
    end
    alias_method :to_h, :output
    alias_method :to_hash, :output
    alias_method :call, :output
    alias_method :execute, :output


    def [](key)
      output[key]
    end

    private

    def _transforms_output(output)
      middlewares = self.class.dsl.instance_variable_get(:@transform_output)
      run_middlewares(middlewares, output)
    end

    def _transforms_input(input)
      middlewares = self.class.dsl.instance_variable_get(:@transform_input)
      run_middlewares(middlewares, input)
    end

    def prepare_input(input)
      case input
      when ->(str) { str.class <= String }
        JSONAdapter.call(input)
      else
        input
      end
    end

    def run_middlewares(middlewares, input)
      if middlewares
        middlewares.inject(input) do |out, proccess|
          proccess.call(out)
        end
      else
        input
      end
    end
  end
end
