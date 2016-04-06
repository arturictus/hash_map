module HashMap
  class JSONAdapter
    class InvalidJOSN < StandardError; end
    def self.call(string)
      JSON[string]
    rescue JSON::ParserError
      fail InvalidJOSN, "[HashMap Error] using: `map` with invalid JSON, please check your json before mapping"
    end
  end
end
