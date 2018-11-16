require 'rails_helper'

describe Entity::V1::APIRateLimit do
  let(:counter_options) { { api_name: 'test_api', limit: 50, period: 1.hour, discriminator: 'discriminator' } }
  let(:counter) { APIRateCounter.get_or_add(counter_options) }

  subject { described_class.new(counter).as_json }

  it { expect(subject[:api_name]).to eq counter.api_name }
  it { expect(subject[:limit]).to eq counter.limit }
  it { expect(subject[:remaining]).to eq counter.remaining }
  it { expect(subject[:reset_at]).to eq counter.reset_at.to_i }
end
