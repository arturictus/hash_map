module HashMap
  Base = Struct.new(:original) do
    include ToDSL
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
