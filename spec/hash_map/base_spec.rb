require 'spec_helper'
module HashMap
  describe Base do
    let(:original) do
      {
        name: 'Artur',
        first_surname: 'hello',
        second_surname: 'world',
        address: {
          postal_code: 12_345,
          country: {
            name: 'Spain',
            language: 'ES'
          }
        },
        email: 'asdf@sdfs.com',
        phone: nil
      }
    end

    class ProfileMapper < HashMap::Base
      property :first_name, from: :name
      property :last_name do |input|
        "#{input[:first_surname]} #{input[:second_surname]}"
      end
      property :language,
               from: [:address, :country, :language],
               transform: proc { |_, value| value.downcase }

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

    subject { ProfileMapper.new(original) }

    it { expect(subject[:first_name]).to eq original[:name] }
    it { expect(subject[:language]).to eq original[:address][:country][:language] }
    it { expect(subject[:last_name]).to eq "#{original[:first_surname]} #{original[:second_surname]}"}
    it { expect(subject[:email][:address]).to eq original[:email]}
    it { expect(subject[:email][:type]).to eq :work }
    it { expect(subject[:country_name]).to eq 'Spain' }

    describe '#output' do
      it 'has alias :to_h' do
        expect(subject.method(:to_h)).to eq(subject.method(:output))
      end
      it 'has alias :to_hash' do
        expect(subject.method(:to_hash)).to eq(subject.method(:output))
      end
    end
  end
end
