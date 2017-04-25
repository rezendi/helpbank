class CreateLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :links do |t|
      t.integer :user_id
      t.integer :community_id
      t.integer :project_id
      t.integer :muster_id
      t.integer :sequence
      t.string :url
      t.string :name
      t.text :description

      t.timestamps
    end

    add_index :links, :user_id
    add_index :links, :community_id
    add_index :links, :project_id
    add_index :links, :muster_id
  end
end
