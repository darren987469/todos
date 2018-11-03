require 'rails_helper'

describe Helper::TokenAuthenticate do
  let(:payload) { { id: access_token.id } }
  let(:user) { create(:user1) }
  let(:access_token) { create(:token, user: user) }
  let(:token) { JSONWebToken.encode(payload) }
  let(:klass) do
    Class.new do
      include Helper::TokenAuthenticate

      attr_reader :headers

      def initialize(headers)
        @headers = headers
      end
    end
  end
  let(:instance) { klass.new(headers) }

  describe '#token_authenticate!' do
    subject { instance.token_authenticate! }

    context 'when invalid token' do
      let(:headers) { { 'Authorization' => 'token invalid_token' } }

      it { expect { subject }.to raise_error NotAuthenticatedError }
    end

    context 'valid token' do
      let(:headers) { { 'Authorization' => "token #{token}" } }

      it 'sets and returns @access_token' do
        expect(subject).to eq access_token
        expect(instance.access_token).to eq access_token
      end
    end
  end

  describe '#toke_user' do
    subject { instance.token_user }

    context 'when invalid token' do
      let(:headers) { { 'Authorization' => 'token invalid_token' } }

      it { expect(subject).to be_nil }
    end

    context 'valid token' do
      let(:headers) { { 'Authorization' => "token #{token}" } }

      it 'returns user' do
        expect(subject).to eq user
      end
    end
  end

  describe '#decoded_auth_token' do
    subject { instance.decoded_auth_token }

    context 'when valid authorization header' do
      let(:headers) { { 'Authorization' => "token #{token}" } }

      it 'returns decoded token' do
        expect(subject.to_json).to eq payload.to_json
      end
    end

    context 'when invalid authorization header' do
      let(:headers) { { 'Authorization' => 'some_token' } }

      it { expect(subject).to be_nil }
    end
  end

  describe '#auth_token' do
    subject { instance.auth_token }

    context 'when valid authorization header' do
      let(:headers) { { 'Authorization' => 'token some_token' } }

      it 'returns token' do
        expect(subject).to eq 'some_token'
      end
    end

    context 'when invalid authorization header' do
      let(:headers) { { 'Authorization' => 'some_token' } }

      it { expect(subject).to be_nil }
    end
  end
end
