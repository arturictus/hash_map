source 'https://rubygems.org'

# Specify your gem's dependencies in hash_map.gemspec
gemspec
gem 'pry'
group :development, :test do
  gem 'simplecov', require: false
  gem 'rubocop', '~> 0.37.2', require: false unless RUBY_VERSION =~ /^1.8/
  gem 'coveralls', require: false
  gem 'codeclimate-test-reporter'

  platforms :mri, :mingw do
    gem 'pry', require: false
    gem 'pry-coolline', require: false
  end
end
