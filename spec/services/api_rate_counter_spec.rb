require 'rails_helper'

describe APIRateCounter do
  let(:limit) { 1 }
  let(:period) { 1.hour }
  let(:api_name) { 'test_api' }
  let(:counter) { described_class.new(api_name, limit, period) }

  before { described_class.redis.flushdb }

  describe '.add' do
    context 'when api not exists' do
      it 'creates APIRateCounter instance and returns it' do
        counter = described_class.add(api_name, limit, period)

        expect(described_class.apis).to have_key(api_name)
        expect(described_class.apis[api_name]).to eq counter
        expect(counter).to be_a_kind_of APIRateCounter
      end
    end

    context 'when api exists' do
      before { described_class.add(api_name, limit, period) }

      it 'returns APIRateCounter without create new instance' do
        expect(APIRateCounter).not_to receive(:new)

        counter = described_class.add(api_name, limit, period)
        expect(counter.api_name).to eq api_name
      end
    end
  end

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
