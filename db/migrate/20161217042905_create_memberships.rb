class CreateMemberships < ActiveRecord::Migration[5.0]
  def change
    create_table :memberships do |t|
      t.integer :user_id
      t.integer :community_id
      t.integer :project_id
      t.integer :role_id
      t.text    :application_info
      t.text    :notes

      t.timestamps
    end
  end
end
