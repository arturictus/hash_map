require 'spec_helper'

describe 'Inheritance' do
  class InhUserMapper < HashMap::Base
    properties :name, :lastname
  end

  class InhAdminMapper < InhUserMapper
    properties :role, :company
  end

  let(:original) do
    {
      name: 'John',
      lastname: 'Doe',
      role: 'Admin',
      company: 'ACME'
    }
  end

  it 'InhUserMapper' do
    map = InhUserMapper.map(original)
    expect(map[:name]).to eq original[:name]
    expect(map[:lastname]).to eq original[:lastname]
    expect(map[:role]).to eq nil
    expect(map[:company]).to eq nil
  end
  it 'InhAdminMapper' do
    map = InhAdminMapper.map(original)
    expect(map[:name]).to eq original[:name]
    expect(map[:lastname]).to eq original[:lastname]
    expect(map[:role]).to eq original[:role]
    expect(map[:company]).to eq original[:company]
  end
end
