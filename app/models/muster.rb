class Muster < ApplicationRecord
  belongs_to :project
  has_many :users, :through => :labors
  has_many :images
  has_many :labors
  has_many :check_ins
  has_many :links
  
  def approved_images
    images.where(image_type:Image::APPROVED)
  end
  
  def own_labors(user)
    return labors.where(user_id:user.id).count
  end
  
  def rated_labors(user)
    labor_ids = labors.map{|l|l.id}
    Rating.where(user_id:user.id).where("labor_id IN (?)", labor_ids).count
  end

  def has_unrated_labors(user)
    return labors.count > rated_labors(user) + own_labors(user)
  end
  
  def to_s
    "#{description} at #{location} at #{start_time}"
  end
end
