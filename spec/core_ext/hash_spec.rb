require 'spec_helper'

class UserMapper < HashMap::Base
  property :name
  from_child :social do
    property :email
  end
end

describe 'Hash extesion' do
  let(:user_hash) { {name: 'John', social: { email: 'JohnWick@gmail.com' }} }
  context 'Valid mapper' do
    subject { user_hash.hash_map_with(UserMapper) }

    it { expect(subject[:name]).to eq user_hash[:name] }
    it { expect(subject[:email]).to eq user_hash[:social][:email] }
  end
end
