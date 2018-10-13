require 'rails_helper'

describe TodoListshipPolicy do
  subject { described_class.new(user, todo_listship) }

  let(:todo_list) { create(:todo_list) }
  let(:user) { create(:user1) }

  context 'user deletes himself' do
    let(:todo_listship) { create(:todo_listship, todo_list: todo_list, user: user) }

    it { should_not permit(:delete) }
  end

  context 'user deletes member who' do
    let(:another_user) { create(:user2) }
    let(:todo_listship) { create(:todo_listship, todo_list: todo_list, user: another_user, role: :admin) }

    context 'has higher permission' do
      before { create(:todo_listship, todo_list: todo_list, user: user, role: :user) }

      it { should_not permit(:delete) }
    end

    context 'has equal permission' do
      before { create(:todo_listship, todo_list: todo_list, user: user, role: :admin) }

      it { should_not permit(:delete) }
    end

    context 'has lower permission' do
      before { create(:todo_listship, todo_list: todo_list, user: user, role: :owner) }

      it { should permit(:delete) }
    end
  end
end
