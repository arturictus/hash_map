require 'spec_helper'
require File.join(HashMap.root, 'lib/hash_map/dsl')

module HashMap
  describe DSL do
    def find_by_key(attrs, key)
      found = nil
      attrs.each do |struct|
        found = struct if struct[:key] == key
        break if found
      end
      found
    end
    describe 'Integration' do
      class TryDSL
        extend ToDSL
        property :first_name, from: :name
        property(:last_name) { |input| "#{input[:first_surname]} #{input[:second_surname]}" }
        property :language, from: [:country, :language], transform: proc {|context, value| value.downcase }

        # To ensure we keep maintaining old implementation
        from_children :address do
          property :code, from: :postal_code
          from_child :country do
            property :country_name
          end
        end

        to_child :email do
          property :address, from: :email
          property :type, default: :work
        end
        property :telephone, from: :phone
      end

      let(:const) { TryDSL }
      let(:data_structure) do
        [
          { key: [:first_name], from: [:name] },
          { key: [:last_name], proc: proc { |input| "#{input[:first_surname]} #{input[:second_surname]}" } },
          { key: [:language], from: [:country, :language], transform: proc {|context, value| value.downcase } },
          { key: [:country_name], from: [:address, :country, :country_name] },
          { key: [:email, :address], from: [:email] },
          { key: [:email, :type], from: [:type], default: :work },
          { key: [:code], from: [:address, :postal_code] }
        ]
      end
      let(:attributes) { const.attributes }
      it { expect(attributes.first).to eq data_structure.first }
      it do
        expect(Fusu.try(find_by_key(attributes, [:last_name]), :[], :proc))
          .to be_a Proc
      end
      it do
        expect(Fusu.try(find_by_key(attributes, [:language]), :[], :from))
          .to eq(find_by_key(data_structure, [:language])[:from])
      end
      it do
        expect(Fusu.try(find_by_key(attributes, [:language]), :[], :transform))
          .to be_a Proc
      end
      it do
        expect(Fusu.try(find_by_key(attributes, [:country_name]), :[], :from))
          .to eq(find_by_key(data_structure, [:country_name])[:from])
      end
      it do
        expect(Fusu.try(find_by_key(attributes, [:code]), :[], :from))
          .to eq(find_by_key(data_structure, [:code])[:from])
      end
      it do
        expect(Fusu.try(find_by_key(attributes, [:email, :address]), :[], :from))
          .to eq(find_by_key(data_structure, [:email, :address])[:from])
      end
      it do
        expect(Fusu.try(find_by_key(attributes, [:code]), :[], :from))
          .to eq(find_by_key(data_structure, [:code])[:from])
      end
      it do
        expect(Fusu.try(find_by_key(attributes, [:email, :type]), :[], :from))
          .to eq(find_by_key(data_structure, [:email, :type])[:from])
      end
      it do
        expect(Fusu.try(find_by_key(attributes, [:email, :type]), :[], :default))
          .to eq(find_by_key(data_structure, [:email, :type])[:default])
      end
    end

    describe 'properties' do
      class TryProperties
        extend ToDSL
        properties :name, :address, :house
      end
      let(:data_structure) do
        [
          { key: [:name], from: [:name] },
          { key: [:address], from: [:address] },
          { key: [:house], from: [:house] }
        ]
      end
      let(:const) { TryProperties }
      let(:attributes) { const.attributes }
      it do
        expect(Fusu.try(find_by_key(attributes, [:name]), :[], :from))
          .to eq(find_by_key(data_structure, [:name])[:from])
      end
      it do
        expect(Fusu.try(find_by_key(attributes, [:address]), :[], :from))
          .to eq(find_by_key(data_structure, [:address])[:from])
      end
      it do
        expect(Fusu.try(find_by_key(attributes, [:house]), :[], :from))
          .to eq(find_by_key(data_structure, [:house])[:from])
      end
    end
    describe 'collection' do
      class Collectable; end
      class TryCollection
        extend ToDSL
        collection :collectable, mapper: Collectable
        collection :numbers, mapper: proc { |n| n.to_i }
      end

      let(:data_structure) do
        [
          { key: [:collectable], from: [:collectable], mapper: Collectable, is_collection: true },
          { key: [:numbers], from: [:numbers], mapper: proc { |n| n.to_i }, is_collection: true },
        ]
      end
      let(:const) { TryCollection }
      let(:attributes) { const.attributes }
      it do
        expect(Fusu.try(find_by_key(attributes, [:collectable]),:[], :mapper))
          .to eq(find_by_key(data_structure, [:collectable])[:mapper])
      end
      it do
        expect(Fusu.try(find_by_key(attributes, [:collectable]),:[], :is_collection))
          .to eq(find_by_key(data_structure, [:collectable])[:is_collection])
      end
      it do
        expect(Fusu.try(find_by_key(attributes, [:numbers]),:[], :is_collection))
          .to eq(find_by_key(data_structure, [:numbers])[:is_collection])
      end
      it do
        expect(Fusu.try(find_by_key(attributes, [:numbers]),:[], :mapper))
          .to be_a(Proc)
      end
      describe 'errors' do
        it do
          expect do
            class CollectionErrors
              extend ToDSL
              collection :errors
            end
          end.to raise_error DSL::NoMapperForCollection
        end

        it do
          expect do
            class PropertyError
              extend ToDSL
              property :hello, :baz
            end
          end.to raise_error DSL::InvalidOptionsForProperty
        end
      end
    end
  end
end
