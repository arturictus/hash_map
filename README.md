# HashMap

HashMap is a small library that allow you to map hashes with style :).
It will remove from your code many of the ugly navigation inside hashes to
get your needed hash structure.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hash_map'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hash_map

## Usage

Your hash:

```ruby
{
  name: 'Artur',
  first_surname: 'hello',
  second_surname: 'world',
  address: {
    postal_code: 12345,
    country: {
      name: 'Spain',
      language: 'ES'
    }
  },
  email: 'asdf@sdfs.com',
  phone: nil
}
```

Your beautiful Mapper:

```ruby
class ProfileMapper < HashMap::Base
  property :first_name, from: :name

  property :last_name do |input|
    "#{input[:first_surname]} #{input[:second_surname]}"
  end

  property :language, from: [:address, :country, :language]

  from_child :address do
    property :code, from: :postal_code
    from_child :country do
      property :country_name, from: :name
    end
  end

  to_child :email do
    property :address, from: :email
    property :type, default: :work
  end

  property :telephone, from: :phone
end
```

Your wanted hash:

```ruby
ProfileMapper.new(original).to_h
=> {
  first_name: "Artur",
  last_name: "hello world",
  language: "ES",
  code: 12345,
  country_name: "Spain",
  email: {
    address: "asdf@sdfs.com",
    type: :work
  },
  telephone: nil
}
```

Enjoy!

### Examples:
**properties**
```ruby
class Properties < HashMap::Base
  properties :name, :address, :house
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/hash_map. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
