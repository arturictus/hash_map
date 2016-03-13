class String
  # Return the string with the structure from the Mapper
  #
  # api_response = "{\"user\":{\"name\":\"John\",\"surname\":\"Doe\"}}"
  # api_response.hash_map_with(UserMapper)
  def hash_map_with(mapper)
    HashMap::Mapper.new(self, mapper.new).output
  end
end
