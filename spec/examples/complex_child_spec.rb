require 'spec_helper'

describe 'from_child :with, :multiple, :nested' do

  class NestedExample < HashMap::Base
    from_child :passenger_data, :traveller_information do
      property :firstname, from: [:passenger, :first_name]
      property :lastname, from: [:traveller, :surname]
    end
  end

  let(:hash) do
    {
      passenger_data: {
        traveller_information: {
          passenger: {
            first_name: 'Juanito'
          },
          traveller: {
            surname: 'Perez'
          }
        }
      }
    }
  end

  it do
    mapped = NestedExample.map(hash)
    expect(mapped).to hash_mapped('firstname').and_eq('Juanito')
    expect(mapped).to hash_mapped('lastname').and_eq('Perez')
  end
end
