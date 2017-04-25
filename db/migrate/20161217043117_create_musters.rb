class CreateMusters < ActiveRecord::Migration[5.0]
  def change
    create_table :musters do |t|
      t.integer :project_id
      t.string :location
      t.decimal :location_lat
      t.decimal :location_lon
      t.datetime :start_time
      t.datetime :end_time
      t.string :description
      t.text :notes

      t.timestamps
    end
  end
end
