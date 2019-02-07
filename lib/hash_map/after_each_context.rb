module HashMap
  class AfterEachContext
    attr_reader :original, :struct, :value
    def initialize(original, struct, value)
      @original = original
      @struct = struct
      @value = value
    end

    def provided?
      has_key?
    end

    def block?
      !!struct[:proc]
    end

    def has_key?
      return true if block?
      found = true
      struct[:from].reduce(original) do |prv, nxt|
        unless prv.respond_to?(:key?) && prv.key?(nxt)
          found = false
          break
        end
        prv.send(:[], nxt)
      end
      found
    end
  end
end
