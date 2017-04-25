class CreateCheckIns < ActiveRecord::Migration[5.0]
  def change
    create_table :check_ins do |t|
      t.integer :user_id
      t.integer :project_id
      t.integer :muster_id
      t.integer :check_in_type
      t.decimal :location_lat
      t.decimal :location_lon
      t.string :location

      t.timestamps
    end
  end
end
