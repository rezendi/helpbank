class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.integer :community_id
      t.integer :project_type_id
      t.integer :creator_id
      t.string :name
      t.string :slug
      t.string :objective
      t.string :call_to_action
      t.text :description
      t.date :target_date
      t.date :original_target_date
      t.string :video_url
      t.text :notes

      t.timestamps
    end
  end
end
