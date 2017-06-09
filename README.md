# HashMap
[![Build Status](https://travis-ci.org/arturictus/hash_map.svg?branch=master)](https://travis-ci.org/arturictus/hash_map)
[![Gem Version](https://badge.fury.io/rb/hash_map.svg)](https://badge.fury.io/rb/hash_map)
[![](https://img.shields.io/gem/dt/contextuable.svg?style=flat)](https://rubygems.org/gems/hash_map)
[![Code Climate](https://codeclimate.com/github/arturictus/hash_map/badges/gpa.svg)](https://codeclimate.com/github/arturictus/hash_map)
[![Coverage Status](https://coveralls.io/repos/github/arturictus/hash_map/badge.svg?branch=master)](https://coveralls.io/github/arturictus/hash_map?branch=master)
[![Issue Count](https://codeclimate.com/github/arturictus/hash_map/badges/issue_count.svg)](https://codeclimate.com/github/arturictus/hash_map)

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

The collection method always treats the value as an `Array` and it always returns an `Array`. If the value is not an `Array` it will be wrapped in a new one. If the value is `nil` it always returns `[]`.

```ruby
Collections.map({ things: nil})
=> {
    things: []
    numbers: []
}

Collections.map({ numbers: '1'})
=> {
   things: []
   numbers: [1]
}
```
**Options**
Adding a second argument will make it available with the name `options`

```ruby
class UserMapper < HashMap::Base
  properties :name, :lastname
  property :company_name do
    options[:company_name]
  end
end

user = {name: :name, lastname: :lastname}

UserMapper.map(user, company_name: :foo)
#=> {"name"=>:name, "lastname"=>:lastname, "company_name"=>:foo}
```

**Inheritance**
When inheriting from a Mapper child will inherit the properties

```ruby
class UserMapper < HashMap::Base
  properties :name, :lastname
end

class AdminMapper < UserMapper
  properties :role, :company
end

original = {
  name: 'John',
  lastname: 'Doe',
  role: 'Admin',
  company: 'ACME'
}

UserMapper.map(original)
#=> { name: 'John', lastname: 'Doe' }

AdminMapper.map(original)
#=> { name: 'John', lastname: 'Doe', role: 'Admin', company: 'ACME' }

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

### Middlewares

#### transforms_output
```ruby
original = {
  "StatusCode" => 200,
  "ErrorDescription" => nil,
  "Messages" => nil,
  "CompanySettings" => {
    "CompanyIdentity" => {
      "CompanyGuid" => "0A6005FA-161D-4290-BB7D-B21B14313807",
      "PseudoCity" => {
        "Code" => "PARTQ2447"
      }
    },
    "IsCertifyEnabled" => false,
    "IsProfileEnabled" => true,
    "PathMobileConfig" => nil
  }
}

class TransformsOutput < HashMap::Base
  transforms_output  HashMap::UnderscoreKeys
  from_child 'CompanySettings' do
    from_child 'CompanyIdentity' do
      property 'CompanyGuid'
    end
    properties 'IsCertifyEnabled', 'IsProfileEnabled', 'PathMobileConfig'
  end
end

TransformsOutput.call(original)
# => {:company_guid=>"0A6005FA-161D-4290-BB7D-B21B14313807", :is_certify_enabled=>false, :is_profile_enabled=>true, :path_mobile_config=>nil}
```

#### Transforms input

```ruby
original = {
  "StatusCode" => 200,
  "ErrorDescription" => nil,
  "Messages" => nil,
  "CompanySettings" => {
    "CompanyIdentity" => {
      "CompanyGuid" => "0A6005FA-161D-4290-BB7D-B21B14313807",
      "PseudoCity" => {
        "Code" => "PARTQ2447"
      }
    },
    "IsCertifyEnabled" => false,
    "IsProfileEnabled" => true,
    "PathMobileConfig" => nil
  }
}

class TransformsInput < HashMap::Base
  transforms_input  HashMap::UnderscoreKeys
  from_child :company_settings do
    from_child :company_identity do
      property :company_guid
    end
    properties :is_certify_enabled, :is_profile_enabled, :path_mobile_config
  end
end

TransformsInput.call(original)
# => {:company_guid=>"0A6005FA-161D-4290-BB7D-B21B14313807", :is_certify_enabled=>false, :is_profile_enabled=>true, :path_mobile_config=>nil}
```


#### After each

```ruby
class AfterEach < HashMap::Base
  properties :name, :age
  after_each HashMap::BlankToNil, HashMap::StringToBoolean
end

blanks = {
  name: '',
  age: ''
}
booleans = {
  name: 'true',
  age: 'false'
}
AfterEach.call(blanks)
#=> {"name"=>nil, "age"=>nil}

AfterEach.call(booleans)
#=> {"name"=>true, "age"=>false}
```

### JSON Adapter
```ruby
class UserMapper < HashMap::Base
  from_child :user do
    properties :name, :surname
  end
end
json = %Q[{"user":{"name":"John","surname":"Doe"}}]
UserMapper.map(json)
# => {"name"=>"John", "surname"=>"Doe"}
```
### Core Extensions

#### String
```ruby
class UserMapper < HashMap::Base
  from_child :user do
    properties :name, :surname
  end
end
json = %Q[{"user":{"name":"John","surname":"Doe"}}]
json.hash_map_with(UserMapper)
# => {"name"=>"John", "surname"=>"Doe"}
```
#### Hash

```ruby
class UserMapper < HashMap::Base
  from_child :user do
    properties :name, :surname
  end
end
hash = { user: { name: 'John', surname: 'Doe' } }
hash.hash_map_with(UserMapper)
# => {"name"=>"John", "surname"=>"Doe"}
```

### Testing

#### RSpec

__hash_mapped__

```ruby
it do
  output = { name: :hello }
  expect(output).to hash_mapped(:name)
end
```

`from`
```ruby
it do
  original = { first_name: :hello }
  output = { name: :hello }
  expect(output).to hash_mapped(:name).from(original, :first_name)
end

it do
  original = { user: { first_name: :hello } }
  output = { name: :hello }
  expect(output).to hash_mapped(:name).from(original, :user, :first_name)
end

it do
  original = { user: { first_name: :hello } }
  output = { user: { name: :hello } }
  expect(output).to hash_mapped(:user, :name).from(original, :user, :first_name)
end
```

`and_eq`

```ruby
it do
  output = { user: { name: :hello } }
  expect(output).to hash_mapped(:user, :name).and_eq(:hello)
end
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
User.create(MyMapper.map(api_response)) # done
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/hash_map. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
