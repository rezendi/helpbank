class CreateIndexes < ActiveRecord::Migration[5.0]
  def change
    add_index :check_ins, :user_id
    add_index :check_ins, :project_id
    add_index :check_ins, :muster_id

    add_index :communities, :community_type_id
    add_index :communities, :name, :unique => true

    add_index :images, :user_id
    add_index :images, :community_id
    add_index :images, :project_id
    add_index :images, :muster_id
    
    add_index :labors, :user_id
    add_index :labors, :project_id
    add_index :labors, :muster_id
    add_index :labors, :pledge_id
    
    add_index :memberships, :user_id
    add_index :memberships, :community_id
    add_index :memberships, :project_id
    add_index :memberships, :role_id

    add_index :musters, :project_id

    add_index :pledges, :user_id
    add_index :pledges, :project_id

    add_index :posts, :user_id
    add_index :posts, :community_id
    add_index :posts, :project_id
    add_index :posts, :pledge_id
    add_index :posts, :muster_id
    add_index :posts, :image_id
    add_index :posts, :reply_to_post_id
    
    add_index :projects, :community_id
    add_index :projects, :project_type_id
    add_index :projects, :name, :unique => true

    add_index :ratings, :labor_id
    add_index :ratings, :user_id
    add_index :ratings, :status
  end
end
