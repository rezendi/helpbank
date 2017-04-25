class CreatePledges < ActiveRecord::Migration[5.0]
  def change
    create_table :pledges do |t|
      t.integer :user_id
      t.integer :project_id
      t.integer :hours
      t.text :notes

      t.timestamps
    end
  end
end
