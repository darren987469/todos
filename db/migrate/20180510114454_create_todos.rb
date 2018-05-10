class CreateTodos < ActiveRecord::Migration[5.2]
  def change
    create_table :todos do |t|
      t.references :todo_list, index: true
      t.string :description
      t.boolean :complete
      t.datetime :archived_at

      t.timestamps
    end
  end
end
