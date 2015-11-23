require 'spec_helper'
require 'pry'
describe 'Collections' do
  class Things < HashMap::Base
    properties :name, :age
  end

  class Collections < HashMap::Base
    collection :things, mapper: Things
    collection :numbers, mapper: proc { |n| n.to_i }
  end


  let(:original) do
    {
      things: [
        { name: 'one thing', age: 12 },
        { name: 'another thing', age: 8 }
      ],
      numbers: %w(1 2 3)
    }
  end
  subject { Collections.map(original) }
  describe ':things' do
    it { expect(subject[:things]).to match_array original[:things] }
  end
  describe ':numbers' do
    it { expect(subject[:numbers]).to match_array original[:numbers].map(&:to_i) }
  end

  describe 'Errors' do
    let(:original){ { things: nil } }
    it do
      expect { subject }.to raise_error HashMap::Mapper::CanNotMapCollection
    end
  end

  describe 'multiple blocks' do
    class ComplexCollection < HashMap::Base
      from_child :things do
        from_child :inside do
          to_child :collection do
            collection :numbers, mapper: proc { |n| n.to_i }
          end
        end
      end
    end
    let(:original) do
      {
        things: {
          inside: {
            numbers: %w(1 2 3)
          }
        }
      }
    end
    subject { ComplexCollection.map(original) }
    it { expect(subject[:collection][:numbers]).to match_array [1, 2, 3] }
  end
end
