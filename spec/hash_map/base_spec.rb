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

    describe 'Options' do
      let(:company) do
        {
          company_name: 'Super Company',
          company_phone: '+34658149869'
        }
      end

      class OptionMapper < HashMap::Base
        property :first_name, from: :name

        property :company_name do
          options[:company_name]
        end
      end

      subject { OptionMapper.call(original, company)}
      it { expect(subject[:first_name]).to eq original[:name] }
      it { expect(subject[:company_name]).to eq company[:company_name] }
    end

    class ProfileMapper < HashMap::Base
      property :first_name, from: :name
      property :last_name do |input|
        "#{input[:first_surname]} #{input[:second_surname]}"
      end
      property :language,
               from: [:address, :country, :language]

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

    describe 'JSON string' do
      context 'Valid JSON' do
        let(:original) { "{\"name\":\"Artur\",\"first_surname\":\"hello\",\"second_surname\":\"world\",\"address\":{\"postal_code\":12345,\"country\":{\"name\":\"Spain\",\"language\":\"ES\"}},\"email\":\"asdf@sdfs.com\",\"phone\":null}" }
        let(:parsed_original) { JSON[original] }
        it { expect(subject[:first_name]).to eq parsed_original['name'] }
        it { expect(subject['first_name']).to eq parsed_original['name'] }
        it {
          expect(subject['language']).to eq parsed_original['address']['country']['language']
        }
        it { expect(subject['last_name']).to eq  "#{parsed_original['first_surname']} #{parsed_original['second_surname']}"}
        it { expect(subject['email']['address']).to eq  parsed_original['email']}
        it { expect(subject['email']['type']).to eq :work }
      end

      context 'Invalid JSON' do
        let(:original) { "{\"name\":\"Artur\", hello: nil}" }
        it 'will fail with exception' do
          expect{ subject.mapper }.to raise_error HashMap::JSONAdapter::InvalidJOSN
        end
      end
    end

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
