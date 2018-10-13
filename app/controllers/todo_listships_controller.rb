# frozen_string_literal: true

class TodoListshipsController < ApplicationController
  def create
    operation.create
  rescue Pundit::NotAuthorizedError
    flash[:alert] = 'You cannot add member.'
  rescue TodoListChannel::TodoListshipOperations::UserNotFound
    flash[:alert] = 'No such user.'
  ensure
    redirect_to edit_todo_list_path(@todo_list)
  end

  def update
    operation.update
  rescue Pundit::NotAuthorizedError
    flash[:alert] = 'You cannot perform this action.'
  ensure
    redirect_to edit_todo_list_path(@todo_list)
  end

  def destroy
    operation.destroy
  rescue Pundit::NotAuthorizedError
    flash[:alert] = 'You cannot perform this action.'
  ensure
    redirect_to edit_todo_list_path(@todo_list)
  end

  private

  def todo_list
    @todo_list ||= current_user.todo_lists.find(params[:todo_list_id])
  end

  def todo_listship
    @todo_listship ||= todo_list.todo_listships.find(params[:id])
  end

  def operation
    TodoListChannel::TodoListshipOperations.new(current_user, params, todo_list)
  end
end
