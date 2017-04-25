class CreateRatings < ActiveRecord::Migration[5.0]
  def change
    create_table :ratings do |t|
      t.integer :labor_id
      t.integer :user_id
      t.integer :status, :default => 0
      t.integer :stars
      t.text :notes

      t.timestamps
    end
  end
end
