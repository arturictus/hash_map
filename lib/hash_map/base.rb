module HashMap
  class Base
    include ToDSL
    delegate :[], to: :output

    def self.map(input)
      new(input).output
    end
    singleton_class.send(:alias_method, :call, :map)

    attr_accessor :original
    def initialize(original)
      @original = original
    end

    def mapper
      self.original = HashMap::JSONAdapter.call(original) if original.is_a? String
      @mapper ||= Mapper.new(original, self)
    end

    def output
      @output ||= mapper.output
    end
    alias_method :to_h, :output
    alias_method :to_hash, :output
  end
end
