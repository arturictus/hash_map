require 'spec_helper'

describe 'Matchers' do
  it do
    output = { name: :hello }
    expect(output).to hash_mapped(:name)
  end
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

  it do
    output = { user: { name: :hello } }
    expect(output).to hash_mapped(:user, :name).and_eq(:hello)
  end
  it do
    output = { 'user' => { 'name' => :hello } }
    expect(output).to hash_mapped('user', 'name').and_eq(:hello)
  end

  describe 'failure messages' do
    before { pending 'execute just to see error messages' }
    let(:original) { {} }
    let(:output) { {} }
    it { expect(output).to hash_mapped(:name) }
    it { expect(output).to hash_mapped(:name).from(original, :first_name) }
    it { expect(output).to hash_mapped(:name).from(original, :user, :first_name) }
    it do
      expect(output).to hash_mapped(:user, :name).from(original, :user, :first_name)
    end
    it do
      output = { user: { name: 'bar' }}
      expect(output).to hash_mapped(:user, :name).and_eq(:hello)
    end
  end
end
