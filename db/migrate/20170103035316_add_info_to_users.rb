class AddInfoToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :role_id, :integer
    add_column :users, :name, :string
    add_column :users, :description, :text
    add_column :users, :notes, :text
    add_column :users, :date_of_birth, :date
  end
end
