require 'rails_helper'

describe TodoList, type: :model do
  let(:todo_list) { create(:todo_list) }
  let(:user) { create(:user1) }

  describe 'self.build' do
    subject { described_class.build(name: 'list', user: user) }

    it 'create todo_list with given name' do
      expect { subject }.to change { TodoList.count }.by(1)
      expect(TodoList.last.name).to eq 'list'
    end

    it 'create todo_listship with role owner for user' do
      expect { subject }.to change { TodoListship.count }.by(1)
      todo_listship = TodoListship.last
      expect(todo_listship.user).to eq user
      expect(todo_listship.role).to eq 'owner'
    end
  end

  describe '#log_tag' do
    it { expect(todo_list.log_tag).to eq "todo_list_#{todo_list.id}" }
  end
end
