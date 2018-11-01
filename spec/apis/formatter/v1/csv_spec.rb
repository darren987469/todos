require 'rails_helper'

describe Formatter::V1::CSV do
  let(:klass) do
    Class.new(Grape::Entity) do
      expose :key1
      expose :key2
    end
  end
  let(:object) { klass.new(OpenStruct.new(key1: 'value1', key2: 2)) }
  let(:env) { {} }

  describe '.call' do
    subject { described_class.call(object, env) }

    context 'when object is not present' do
      let(:object) { [] }

      it { expect(subject).to be_nil }
    end

    context 'when object is present' do
      it 'returns content with csv format' do
        expected = CSV.generate(headers: true) do |csv|
          csv << object.as_json.keys
          csv << object.as_json.values
        end

        expect(subject).to eq expected
      end
    end
  end
end
