require 'spec_helper'

describe HashMap do
  it 'has a version number' do
    expect(HashMap::VERSION).not_to be nil
  end

  describe "deep reject" do
    it 'one level' do
      out = HashMap.deep_reject({hello: 'hello', thing: "thing"}) do |k, v|
        k == :thing
      end
      expect(out).to hash_mapped(:hello).and_eq('hello')
      expect(out).not_to hash_mapped(:thing)
    end

    it 'muptiple levels' do
      input = {
                hello: 'hello', thing: :reject,
                reject: true,
                nested: { reject: true , thing: true, reject: true,
                          nested: { thing: true, reject: true } }
              }
      out = HashMap.deep_reject(input) do |k, v|
              k == :reject || v == :reject
            end
      expect(out).to hash_mapped(:hello).and_eq('hello')
      expect(out).not_to hash_mapped(:reject)

      expect(out).to hash_mapped(:nested, :thing).and_eq(true)
      expect(out).to hash_mapped(:nested, :nested, :thing).and_eq(true)
      expect(out).not_to hash_mapped(:nested, :nested, :reject)
    end
  end
end
