module HashMap
  class Base < Struct.new(:original)
    include ToDSL
    delegate :[], to: :output

    def self.map(input)
      new(input).output
    end

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
