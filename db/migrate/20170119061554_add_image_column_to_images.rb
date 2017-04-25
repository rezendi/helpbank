class AddImageColumnToImages < ActiveRecord::Migration[5.0]
  def change
    add_attachment :images, :file
  end
end
