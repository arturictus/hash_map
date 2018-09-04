$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'coveralls'
Coveralls.wear!
require 'hash_map'
require 'pry'
require 'hash_map/matchers'
require 'rails'

RSpec.configure do |config|
  config.include HashMap::Matchers
end
