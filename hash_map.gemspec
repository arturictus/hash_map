# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hash_map/version'

Gem::Specification.new do |spec|
  spec.name          = "hash_map"
  spec.version       = HashMap::VERSION
  spec.authors       = ["Artur Pañach"]
  spec.email         = ["arturictus@gmail.com"]

  spec.summary       = %q{Library to map easily hashes.}
  spec.description   = %q{Nice DSL to convert hash structure to different one.}
  spec.homepage      = "https://github.com/arturictus/hash_map"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_dependency "fusu", "~> 0.2.1"
end
