module HashMap
  class Mapper < Struct.new(:original, :data_structure)
    # attr_reader :original, :data_structure
    # def initialize(original, data_structure)
    #   @
    # end
    def output
      new_hash = {}
      data_structure.each do |struc|
        value = get_value(struc)
        new_hash.deep_merge! build_keys(struc[:key], value)
      end
      new_hash
    end

    private

    def get_value(struct)
      value = if block = struct[:proc]
        block.call(original)
      elsif struct[:from]
        get_value_from_key(struct)
      end
      nil_to_default(value, struct)
    end

    def get_value_from_key(struct)
      struct[:from].inject(original) do |output, k|
        break unless output.respond_to?(:[])
        output.send(:[], k)
      end
    end

    def build_keys(ary, value)
      ary.reverse.inject(value) do |a, n|
        { n => a }
      end
    end

    def nil_to_default(value, struct)
      value || struct[:default]
    end
  end
end
