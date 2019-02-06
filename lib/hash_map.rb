require 'hash_map/version'
require 'fusu'
module HashMap
  def self.root
    File.expand_path '../..', __FILE__
  end

  class KeyNotProvided
    def to_s
      'nil'
    end
    def to_json
      nil
    end
    def as_json
      nil
    end
  end
end
require 'hash_map/dsl'
require 'hash_map/mapper'
require 'hash_map/base'
require 'hash_map/json_adapter'
require 'hash_map/plugins'
