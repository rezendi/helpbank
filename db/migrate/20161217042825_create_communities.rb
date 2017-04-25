class CreateCommunities < ActiveRecord::Migration[5.0]
  def change
    create_table :communities do |t|
      t.integer :community_type_id
      t.integer :stars_to_create_a_project
      t.string :name
      t.string :slug
      t.text :description
      t.text :notes

      t.timestamps
    end
  end
end
