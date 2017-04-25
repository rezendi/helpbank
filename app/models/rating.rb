class Rating < ApplicationRecord
  belongs_to :labor
  belongs_to :user
  
  def stars_string
    "*" * stars
  end
end
