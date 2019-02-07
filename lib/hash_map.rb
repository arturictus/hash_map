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
    def as_json(arg = nil)
      nil
    end
  end

  def self.deep_reject(hash, &block)
    hash.each_with_object(Fusu::HashWithIndifferentAccess.new) do |(k, v), memo|
      unless block.call(k, v)
        if v.is_a?(Hash)
          memo[k] = deep_reject(v, &block)
        else
          memo[k] = v
        end
      end
    end
  end
end
require 'hash_map/dsl'
require 'hash_map/after_each_context'
require 'hash_map/mapper'
require 'hash_map/base'
require 'hash_map/json_adapter'
require 'hash_map/plugins'
