require 'rails_helper'

describe TodoListsHelper do
  describe '#role_options' do
    it { expect(helper.role_options).to eq [%w[Admin admin], %w[User user]] }
  end
end
