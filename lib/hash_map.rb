require "hash_map/version"

require 'active_support/all'
module HashMap
  # Your code goes here...
  def self.root
    File.expand_path '../..', __FILE__
  end
end
require 'hash_map/mapper'
