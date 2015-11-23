require 'spec_helper'
describe 'Defaults' do
  class Defaults < HashMap::Base
    property :admin
    property :cool, default: :mostly
    property :no_exist
    property :no_exist_with_default, default: :ummm
  end

  let(:original) do
    {
      admin: false,
      cool: nil,
    }
  end
  subject { Defaults.map(original) }
  it { expect(subject[:admin]).to eq false }
  it { expect(subject[:cool]).to eq :mostly }
  it { expect(subject[:no_exist]).to be_nil }
  it { expect(subject[:no_exist_with_default]).to eq :ummm }
end
