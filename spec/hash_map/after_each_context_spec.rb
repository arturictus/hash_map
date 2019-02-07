require 'spec_helper'
module HashMap
  describe AfterEachContext do
    context 'not nested' do
      let(:struct) do
        { key: [:first_name], from: [:name] }
      end
      it "when provided" do
        inst = described_class.new({name: 'hello'}, struct, 'hello')
        expect(inst.block?).to be false
        expect(inst.provided?).to be true
        expect(inst.has_key?).to be true
      end
      it "when not provided" do
        inst = described_class.new({another: 'hello'}, struct, 'hello')
        expect(inst.block?).to be false
        expect(inst.provided?).to be false
        expect(inst.has_key?).to be false
      end
    end
    context 'nested' do
      let(:struct) do
        { key: [:language], from: [:address, :country, :language] }
      end
      it "when provided" do
        inst = described_class.new({address: {country: {language: 'es'}}}, struct, 'es')
        expect(inst.block?).to be false
        expect(inst.provided?).to be true
        expect(inst.has_key?).to be true
      end
      it "when not provided" do
        inst = described_class.new({another: 'hello'}, struct, 'hello')
        expect(inst.block?).to be false
        expect(inst.provided?).to be false
        expect(inst.has_key?).to be false
      end
    end
    context 'block' do
      let(:struct) do
        { key: [:last_name], proc: proc { |input| "#{input[:first_surname]} #{input[:second_surname]}" } }
      end
      it "always is provided" do
        inst = described_class.new({first_surname: "Doe", second_surname: "Gonzalez"}, struct, nil)
        expect(inst.block?).to be true
        expect(inst.provided?).to be true
        expect(inst.has_key?).to be true
      end
    end
  end
end
