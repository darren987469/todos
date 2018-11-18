require 'rails_helper'

describe Helper::Base do
  include Helper::Base

  let(:user) { create(:user1) }

  describe '#authenticate_user!' do
    context 'when current_user exists' do
      it 'returns current_user' do
        def current_user
          user
        end
        expect(authenticate_user!).to eq user
      end
    end

    context 'when current_user not exists' do
      it 'raise error' do
        def current_user
          nil
        end
        expect { authenticate_user! }.to raise_error NotAuthenticatedError
      end
    end
  end

  describe '#current_user' do
    context 'when instance variable @current_user exists' do
      it 'returns @current_user' do
        @current_user = user
        expect(current_user).to eq user
      end
    end

    context 'when instance variable @current_user not exists' do
      it 'returns devise_user' do
        def devise_user
          user
        end
        expect(current_user).to eq user
      end
    end
  end
end
