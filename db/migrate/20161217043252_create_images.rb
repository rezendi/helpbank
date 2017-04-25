class CreateImages < ActiveRecord::Migration[5.0]
  def change
    create_table :images do |t|
      t.integer :user_id
      t.integer :community_id
      t.integer :project_id
      t.integer :muster_id
      t.integer :sequence
      t.integer :image_type
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
