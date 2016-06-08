require 'spec_helper'

describe 'TransformOutput' do

  class TransformsOutput < HashMap::Base
    transforms_output  HashMap::UnderscoreKeys
    from_child 'CompanySettings' do
      from_child 'CompanyIdentity' do
        property 'CompanyGuid'
      end
      properties 'IsCertifyEnabled', 'IsProfileEnabled', 'PathMobileConfig'
    end
  end

  let(:original) do
    {
      "StatusCode" => 200,
      "ErrorDescription" => nil,
      "Messages" => nil,
      "CompanySettings" => {
        "CompanyIdentity" => {
          "CompanyGuid" => "0A6005FA-161D-4290-BB7D-B21B14313807",
          "PseudoCity" => {
            "Code" => "PARTQ2447"
          }
        },
        "IsCertifyEnabled" => false,
        "IsProfileEnabled" => true,
        "PathMobileConfig" => nil
      }
    }
  end
  subject { TransformsOutput.map(original) }
  it { expect(subject.fetch(:company_guid)).to eq "0A6005FA-161D-4290-BB7D-B21B14313807" }
  it { expect(subject.fetch(:is_certify_enabled)).to eq false }
  it { expect(subject.fetch(:is_profile_enabled)).to eq true }
  it { expect(subject.fetch(:path_mobile_config)).to eq nil }
end

describe 'TransformsInput' do

  class TransformsInput < HashMap::Base
    transforms_input  HashMap::UnderscoreKeys
    from_child :company_settings do
      from_child :company_identity do
        property :company_guid
      end
      properties :is_certify_enabled, :is_profile_enabled, :path_mobile_config
    end
  end

  let(:original) do
    {
      "StatusCode" => 200,
      "ErrorDescription" => nil,
      "Messages" => nil,
      "CompanySettings" => {
        "CompanyIdentity" => {
          "CompanyGuid" => "0A6005FA-161D-4290-BB7D-B21B14313807",
          "PseudoCity" => {
            "Code" => "PARTQ2447"
          }
        },
        "IsCertifyEnabled" => false,
        "IsProfileEnabled" => true,
        "PathMobileConfig" => nil
      }
    }
  end
  subject { TransformsOutput.map(original) }
  it { expect(subject.fetch(:company_guid)).to eq "0A6005FA-161D-4290-BB7D-B21B14313807" }
  it { expect(subject.fetch(:is_certify_enabled)).to eq false }
  it { expect(subject.fetch(:is_profile_enabled)).to eq true }
  it { expect(subject.fetch(:path_mobile_config)).to eq nil }
end
