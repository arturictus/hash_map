require 'spec_helper'
describe 'Methods' do
  class Methods < HashMap::Base
    property :common_names do
      common_names
    end

    property :date do |original|
      parse_date original[:date]
    end

    property :class_name do
      self.class.name
    end

    def common_names
      %w(John Doe)
    end

    def parse_date(date)
      date.strftime('%H:%M')
    end
  end

  let(:original) do
    {
      date: Time.new(2015, 12, 04, 10, 12)
    }
  end
  subject { Methods.map(original) }
  it { expect(subject[:common_names]).to eq %w(John Doe) }
  it { expect(subject[:date]).to eq original[:date].strftime('%H:%M') }
  it { expect(subject[:class_name]).to eq 'Methods' }
end
