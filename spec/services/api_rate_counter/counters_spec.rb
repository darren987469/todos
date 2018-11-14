require 'rails_helper'

describe APIRateCounter::Counters do
  let(:limit) { 1 }
  let(:period) { 1.hour }
  let(:api_name) { 'test_api' }
  let(:discriminator) { 'token_id' }
  let(:counter_params) { [api_name, { limit: limit, period: period, discriminator: discriminator }] }
  let(:counters) { described_class.new }

  describe '#add' do
    context 'when counter not exists' do
      it 'creates APIRateCounter instance and returns it' do
        counter = counters.add(*counter_params)
        expect(counter).to be_a_kind_of APIRateCounter
      end
    end

    context 'when counter exists' do
      let!(:counter) { counters.add(*counter_params) }

      it 'returns APIRateCounter without create new instance' do
        expect(APIRateCounter).not_to receive(:new)

        subject = counters.add(*counter_params)
        expect(subject).to eq counter
      end
    end
  end

  describe '#get' do
    subject { counters.get(api_name, discriminator) }

    context 'counter not exists' do
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'counter exists' do
      let!(:counter) { counters.add(*counter_params) }

      it 'returns counter' do
        expect(subject).to eq counter
      end
    end
  end
end
