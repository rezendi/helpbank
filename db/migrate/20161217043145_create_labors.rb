class CreateLabors < ActiveRecord::Migration[5.0]
  def change
    create_table :labors do |t|
      t.integer :user_id
      t.integer :project_id
      t.integer :muster_id
      t.integer :pledge_id
      t.integer :status, :default => 0
      t.datetime :start_time
      t.integer :hours
      t.text :notes

      t.timestamps
    end
  end
end
