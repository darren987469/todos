require 'rails_helper'

describe APIRateCounter do
  let(:limit) { 1 }
  let(:period) { 1.hour }
  let(:api_name) { 'test_api' }
  let(:discriminator) { 'token_id' }
  let(:counter_params) { [api_name, { limit: limit, period: period, discriminator: discriminator }] }
  let(:counter) { described_class.new(*counter_params) }

  before { described_class.redis.flushdb }

  describe '#increment' do
    it 'default increment count by 1' do
      counter.increment
      expect(counter.count).to eq 1

      counter.increment
      expect(counter.count).to eq 2
    end

    it 'increment amount if given' do
      counter.increment(10)
      expect(counter.count).to eq 10
    end

    it 'sets expire for data in redis' do
      counter.increment
      expect(counter.reset_in).to eq period
    end
  end

  describe '#reset_at' do
    it 'returns reset time' do
      Timecop.freeze(now = Time.current) do
        counter.increment
        expect(counter.reset_at).to eq(now + counter.reset_in)
      end
    end
  end

  describe '#remaining' do
    context 'when count > limit' do
      let(:limit) { 1 }

      it 'returns 0' do
        counter.increment
        expect(counter.remaining).to eq 0
      end
    end

    context 'when count < limit' do
      let(:limit) { 100 }

      it 'returns remaining count' do
        counter.increment
        expect(counter.remaining).to eq(limit - counter.count)
      end
    end
  end
end
