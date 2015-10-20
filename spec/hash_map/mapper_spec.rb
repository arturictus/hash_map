require 'spec_helper'
module HashMap
  describe Mapper do
    let(:original) do
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
    end
    let(:data_structure) do
      [
        { key: [:first_name], from: [:name] },
        { key: [:last_name], proc: proc { |input| "#{input[:first_surname]} #{input[:second_surname]}" } },
        { key: [:language], from: [:address, :country, :language], transform: proc {|context, value| value.downcase } },
        { key: [:email, :address], from: [:email] },
        { key: [:email, :type], default: :work },
      ]
    end
    subject do
      described_class.new(original, data_structure).output
    end

    it { expect(subject[:first_name]).to eq original[:name] }
    it { expect(subject[:language]).to eq original[:address][:country][:language] }
    it { expect(subject[:last_name]).to eq  "#{original[:first_surname]} #{original[:second_surname]}"}
    it { expect(subject[:email][:address]).to eq  original[:email]}
    it { expect(subject[:email][:type]).to eq :work }
  end
end
