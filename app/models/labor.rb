class Labor < ApplicationRecord
  belongs_to :user
  belongs_to :project
  belongs_to :pledge, required: false
  belongs_to :muster, required: false
  has_many :ratings
  
  REJECTED = -1
  SUBMITTED = 0
  APPROVED = 1
  
  def string_for_status
    return "Rejected" if status == -1
    return "Submitted" if status == 0
    return "Approved" if status == 1
  end
  
  def average_rating
    ratings.reduce(0){|sum,r|sum + r.stars}.to_f / ratings.count
  end
  
  def check_ins
    muster ? muster.check_ins.where(user_id:user.id) : []
  end

  def to_s
    "#{hours} hours #{user}"
  end
end
