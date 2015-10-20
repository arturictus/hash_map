require 'spec_helper'
require File.join(HashMap.root, 'lib/hash_map/dsl')
module HashMap
  describe DSL do
    class TryDSL
      include ToDSL
      property :first_name, from: :name
      property(:last_name) { |input| "#{input[:first_surname]} #{input[:second_surname]}" }
      property :language, from: [:country, :language], transform: proc {|context, value| value.downcase }

      from_children :address do
        property :code, from: :postal_code

        from_children :country do
          property :country_name
        end
      end

      to_children :email do
        property :address, from: :email
        property :type, default: :work
      end
      property :telephone, from: :phone
    end

    def find_by_key(attrs, key)
      found = nil
      attrs.each do |struct|
        found = struct if struct[:key] == key
        break if found
      end
      found
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
      expect(find_by_key(attributes, [:last_name]).try(:[], :proc))
        .to be_a Proc
    end
    it do
      expect(find_by_key(attributes, [:language]).try(:[], :from))
        .to eq(find_by_key(data_structure, [:language])[:from])
    end
    it do
      expect(find_by_key(attributes, [:language]).try(:[], :transform))
        .to be_a Proc
    end
    it do
      expect(find_by_key(attributes, [:country_name]).try(:[], :from))
        .to eq(find_by_key(data_structure, [:country_name])[:from])
    end
    it do
      expect(find_by_key(attributes, [:code]).try(:[], :from))
        .to eq(find_by_key(data_structure, [:code])[:from])
    end
    it do
      expect(find_by_key(attributes, [:email, :address]).try(:[], :from))
        .to eq(find_by_key(data_structure, [:email, :address])[:from])
    end
    it do
      expect(find_by_key(attributes, [:code]).try(:[], :from))
        .to eq(find_by_key(data_structure, [:code])[:from])
    end
    it do
      expect(find_by_key(attributes, [:email, :type]).try(:[], :from))
        .to eq(find_by_key(data_structure, [:email, :type])[:from])
    end
    it do
      expect(find_by_key(attributes, [:email, :type]).try(:[], :default))
        .to eq(find_by_key(data_structure, [:email, :type])[:default])
    end
  end
end
