require 'spec_helper'

describe 'after_each' do
  BlankToNil = lambda do |v|
    v.blank? ? nil : v
  end
  StringToBoolean = lambda do |v|
    return false if v == 'false'
    return true if v == 'true'
    v
  end

  class AfterEach < HashMap::Base
    properties :name, :age
    after_each BlankToNil, StringToBoolean
  end

  describe 'blank to nil' do
    let(:original) do
      {
        name: '',
        age: ''
      }
    end

    subject { AfterEach.map(original) }
    it { expect(subject.fetch(:name)).to be_nil }
    it { expect(subject.fetch(:age)).to be_nil }
  end

  describe 'string if false' do
    let(:original) do
      {
        name: 'true',
        age: 'false'
      }
    end

    subject { AfterEach.map(original) }
    it { expect(subject.fetch(:name)).to eq true }
    it { expect(subject.fetch(:age)).to eq false }
  end
end
