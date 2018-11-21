require 'rails_helper'

describe ApplicationPolicy do
  let(:user) { create(:user1) }
  let(:resource) { OpenStruct.new(all: nil) }

  subject { described_class.new(user, resource) }

  describe '#create?' do
    it { expect(subject.create?).to eq false }
  end

  describe '#read?' do
    it { expect(subject.read?).to eq false }
  end

  describe '#update?' do
    it { expect(subject.update?).to eq false }
  end

  describe '#delete?' do
    it { expect(subject.delete?).to eq false }
  end

  describe ApplicationPolicy::Scope do
    describe '#resolve' do
      it 'default scope is all' do
        expect(resource).to receive(:all)
        expect(subject.resolve)
      end
    end
  end
end
