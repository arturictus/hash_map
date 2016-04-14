module HashMap
  class Base
    include ToDSL
    delegate :[], to: :output

    def self.map(input)
      new(input).output
    end
    singleton_class.send(:alias_method, :call, :map)

    attr_reader :original
    def initialize(original)
      @original = prepare_input(original)
    end

    def mapper
      @mapper ||= Mapper.new(original, self)
    end

    def output
      @output ||= mapper.output
    end
    alias_method :to_h, :output
    alias_method :to_hash, :output

    private

    def prepare_input(input)
      case input
      when ->(str) { str.class <= String }
        JSONAdapter.call(input)
      else
        input
      end
    end
  end
end
