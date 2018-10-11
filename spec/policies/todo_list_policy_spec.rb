require 'rails_helper'

describe TodoListPolicy do
  subject { described_class.new(user, todo_list) }

  let(:todo_list) { create(:todo_list) }
  let(:user) { create(:user1) }

  context 'when user is todo_list owner' do
    before { create(:todo_listship, user: user, todo_list: todo_list, role: :owner) }

    it { should permit(:update) }
    it { should permit(:invite_member) }
    it { should permit(:delete) }
  end

  context 'when user is todo_list admin' do
    before { create(:todo_listship, user: user, todo_list: todo_list, role: :admin) }

    it { should permit(:update) }
    it { should permit(:invite_member) }
    it { should_not permit(:delete) }
  end

  context 'when user is todo_list user' do
    before { create(:todo_listship, user: user, todo_list: todo_list, role: :user) }

    it { should_not permit(:update) }
    it { should_not permit(:invite_member) }
    it { should_not permit(:delete) }
  end
end
