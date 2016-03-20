require 'spec_helper'

describe 'reverse_map' do
  let(:hash) do
    {
      the_name: 'John',
      surname: 'Doe',
      phone: '89898983943'
    }
  end
  class User < HashMap::Base
    property :name, from: :the_name
    property :last_name, from: :surname
  end

  let(:up) { User.map(hash) }
  let(:down) { User.reverse_map(up) }
  it { expect(up.fetch(:name)).to eq(hash[:the_name]) }
  it { expect(up.fetch(:last_name)).to eq(hash[:surname]) }
  it { expect(down.fetch(:surname)).to eq(hash[:surname]) }
  it { expect(down.fetch(:the_name)).to eq(hash[:the_name]) }

end
