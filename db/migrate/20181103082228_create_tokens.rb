class CreateTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :tokens do |t|
      t.string :note
      t.string :scopes
      t.references :user

      t.timestamps
    end
  end
end
