# frozen_string_literal: true

require 'rails_helper'

describe User, type: :model do
  let(:todo_list) { create(:todo_list) }
  let(:user) { create(:user, email: 'some@gmail.com', first_name: 'First name', last_name: 'Last name') }

  shared_examples 'full_name' do |method|
    subject { user.send(method) }
    it { expect(subject).to eq 'First name Last name' }
  end

  describe '#full_name' do
    it_behaves_like 'full_name', :full_name
  end

  describe '#name' do
    it_behaves_like 'full_name', :name
  end

  describe '#role_of(todo_list)' do
    it 'return user\'s role of the list' do
      todo_listship = create(:todo_listship, user: user, todo_list: todo_list)

      TodoListship.roles.keys.each do |role|
        todo_listship.update role: role
        expect(user.role_of(todo_list)).to eq role
      end
    end
  end
end
