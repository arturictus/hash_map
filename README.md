# HashMap
[ ![Codeship Status for arturictus/hash_map](https://codeship.com/projects/5900adb0-7452-0133-84a1-52f3970f70f1/status?branch=master)](https://codeship.com/projects/117597)

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
ProfileMapper.map(original)
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
**IMPORTANT:**
- The **output** is a **HashWithIndifferentAccess** you can access the values with strings or symbols.
- The input is transformed as well, that's why you do not need to use strings.

Enjoy!

### Examples:
**No 'from' key needed:**
```ruby
class Clever < HashMap::Base
  property :name # will get value from the key 'name'
  property :address
end
```

**Properties:**
```ruby
class Properties < HashMap::Base
  properties :name, :address, :house
end
```

**Collections:**

You can map collections passing the mapper option, can be another mapper a proc or anything responding to `.call` with one argument.

```ruby
class Thing < HashMap::Base
  properties :name, :age
end

class Collections < HashMap::Base
  collection :things, mapper: Thing
  collection :numbers, mapper: proc { |n| n.to_i }
end
```

**Methods:**

You can create your helpers in the mapper and call them inside the block

```ruby
class Methods < HashMap::Base
  property(:common_names) { names }
  property(:date) { |original| parse_date original[:date] }
  property(:class_name) { self.class.name } #=> "Methods"

  def names
    %w(John Morty)
  end

  def parse_date(date)
    date.strftime('%H:%M')
  end
end
```

**Blocks:**

In **from_child** block when you want to get the value with a block
the value of the child and original will be yielded in this order: child, original

```ruby
class Blocks < HashMap::Base
  from_child :address do
    property :street do |address|
      address[:street].upcase
    end
    property :owner do |address, original|
      original[:name]
    end
    from_child :country do
      property :country do |country|
        country[:code].upcase
      end
    end
  end
  property :name do |original|
    original[:name]
  end
end

hash = {
  name: 'name',
  address:{
    street: 'street',
    country:{
      code: 'es'
    }
  }
}

Blocks.map(hash)
# => {"street"=>"STREET", "owner"=>"name", "country"=>"ES", "name"=>"name"}

```



### Motivation
I got bored of doing this:
```ruby
# this is a hash from an API
hash = JSON.parse(response, :symbolize_names => true)
# hash = {
#   user: {
#     name: 'John',
#     last_name: 'Doe',
#     telephone: '989898',
#     country: {
#       code: 'es'
#     }
#   }
# }

user_hash = hash[:user]
user = User.new
user.name = user_hash[:name]
user.lastname = user_hash[:last_name]
user.phone = Phone.parse(user_hash[:telephone])
user.country = Country.find_by(code: user_hash[:country][:code])

# boring!!!
# and that's a tiny response
```

solution:
```ruby
user = User.new(MyMapper.map(hash)) # done
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/hash_map. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
