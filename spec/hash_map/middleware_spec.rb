require 'spec_helper'

class MarkUnprovidedMapper < HashMap::Base
  after_each HashMap::MarkUnprovided
  property :name, from: :first_name
  property :optional
  from_child  :address do
    property :street
    property :number
  end
  to_child :company do
    property :name, from: :company_name
    property :code, from: :company_code
  end
  property :block do
    'hello'
  end
  property :another_block do
    'hello'
  end
end

class RemoveUnprovidedMapper < MarkUnprovidedMapper
  after_each HashMap::MarkUnprovided
  transforms_output HashMap::RemoveUnprovideds
end


describe 'middlewares' do
  let(:input) do
    { first_name: "Hello", address: { street: "Batu Mejan" }, company_name: "Acme" }
  end
  describe MarkUnprovidedMapper do
    subject { described_class.call(input) }
    it do
      expect(subject).to hash_mapped(:name).and_eq('Hello')
      expect(subject).to hash_mapped(:optional).and_eq( proc { |v|
        v.is_a?(HashMap::KeyNotProvided)
      })
      expect(subject).to hash_mapped(:street).from(input, :address, :street)
      expect(subject).to hash_mapped(:block).and_eq("hello")
      expect(subject).to hash_mapped(:another_block).and_eq("hello")
      expect(subject).to hash_mapped(:company, :name).from(input, :company_name)
      expect(subject).to hash_mapped(:company, :code).and_eq( proc { |v|
        v.is_a?(HashMap::KeyNotProvided)
      })
      expect(subject).to hash_mapped(:number).and_eq( proc { |v|
        v.is_a?(HashMap::KeyNotProvided)
      })
    end
    it do
      expect{ subject.to_json }.not_to raise_error
    end
  end
  describe RemoveUnprovidedMapper do
    subject { described_class.call(input) }
    it do
      expect(subject).to hash_mapped(:name).and_eq('Hello')
      expect(subject).not_to hash_mapped(:optional)
      expect(subject).to hash_mapped(:street).from(input, :address, :street)
      expect(subject).not_to hash_mapped(:number).from(input, :address, :street)
      expect(subject).to hash_mapped(:block).and_eq("hello")
      expect(subject).to hash_mapped(:another_block).and_eq("hello")
      expect(subject).to hash_mapped(:company, :name).from(input, :company_name)
      expect(subject).not_to hash_mapped(:company, :code)
      expect(subject).not_to hash_mapped(:number)
    end
  end
end
