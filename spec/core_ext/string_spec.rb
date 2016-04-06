require 'spec_helper'

class UserMapper < HashMap::Base
  property :name
  from_child :social do
    property :email
  end
end

describe 'String extesion' do
  let(:user_json) { "{\"name\":\"John\",\"social\":{\"email\":\"JohnWick@gmail.com\"}}" }
  let(:parsed_json) { JSON[user_json] }
  context 'Valid mapper' do
    subject { user_json.hash_map_with(UserMapper) }
    it { expect(subject[:name]).to eq parsed_json['name'] }
    it { expect(subject[:email]).to eq parsed_json['social']['email'] }
  end
end
