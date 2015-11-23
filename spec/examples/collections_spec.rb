require 'spec_helper'
describe 'Collections' do
  class Collections < HashMap::Base
    collection :things do

    end
  end

  let(:original) do
    {
      date: Time.new(2015, 12, 04, 10, 12)
    }
  end
  subject { Collections.map(original) }
end
