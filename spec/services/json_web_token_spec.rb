require 'rails_helper'

describe JSONWebToken do
  let(:secret) { Rails.application.secrets.secret_key_base }
  let(:algorithm) { 'HS256' }
  let(:payload) { { token_id: 1 } }

  describe '.encode' do
    subject { described_class.encode(payload) }

    it 'returns token' do
      expect(subject).to eq JWT.encode(payload, secret, algorithm)
    end
  end

  describe '.decode' do
    subject { described_class.decode(token) }

    context 'valid token' do
      let(:token) { JWT.encode(payload, secret, algorithm) }

      it 'returns payload' do
        expect(subject).to be_a HashWithIndifferentAccess
        expect(subject.to_json).to eq payload.to_json
      end
    end

    context 'invalid token' do
      let(:token) { 'invalid' }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end
end
