class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.integer :community_id
      t.integer :project_id
      t.integer :pledge_id
      t.integer :muster_id
      t.integer :update_id
      t.integer :phase_id
      t.integer :image_id
      t.integer :reply_to_post_id
      t.text :content
      t.text :notes

      t.timestamps
    end
  end
end
