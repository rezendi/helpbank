class Membership < ApplicationRecord
  belongs_to :community
  belongs_to :user
  
  DECLINED = -2
  APPLICANT = -1
  MEMBER = 0
  ADMIN = 1
  
  def description
    return "Declined" if role_id == DECLINED
    return "Applicant" if role_id == APPLICANT
    return "Member" if role_id == MEMBER
    return "Admin" if role_id == ADMIN
    return "Unknown"
  end

  def total_hours
    user.hours_for(community).to_i
  end
  
  def total_stars
    user.stars_for(community).to_i
  end
  
  def spent_stars
    total = 0
    for project in user.private_projects_for(community)
      total += project.total_stars
    end
    total
  end
end
