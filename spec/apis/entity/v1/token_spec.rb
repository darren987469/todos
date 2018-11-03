require 'rails_helper'

describe Entity::V1::Token do
  let(:token) { build(:token, note: 'note', scopes: ['read:log']) }

  subject { described_class.new(token).as_json }

  it { expect(subject[:note]).to eq token.note }
  it { expect(subject[:scopes]).to eq token.scopes }
end
