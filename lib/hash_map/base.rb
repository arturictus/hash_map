module HashMap
  class Base < Struct.new(:original)
    include ToDSL
    delegate :[], to: :output

    def mapper
      @mapper ||= Mapper.new(original, self.class.attributes)
    end

    def output
      mapper.output
    end
    alias_method :to_h, :output
  end
end
