# frozen_string_literal: true

class CreateTodoListships < ActiveRecord::Migration[5.2]
  def change
    create_table :todo_listships do |t|
      t.references :user, null: false
      t.references :todo_list, null: false
      t.integer :role, default: 0, null: false

      t.timestamps
    end

    add_index :todo_listships, %i[user_id todo_list_id], unique: true
  end
end
