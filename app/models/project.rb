class Project < ApplicationRecord
  belongs_to :community
  has_many :pledges
  has_many :musters
  has_many :labors
  has_many :images
  has_many :posts
  has_many :links
  include FriendlyId
  friendly_id :name, :use => :slugged

  COMMUNITY_PROJECT = 0
  PRIVATE_PROJECT = 1

  def submitted_images
    images.where(image_type:Image::SUBMITTED)
  end

  def approved_images
    images.where(image_type:Image::APPROVED).where(muster_id:nil)
  end

  def submitted_labors
    labors.where(status:Labor::SUBMITTED)
  end
  
  def approved_labors
    labors.where(status:Labor::APPROVED)
  end
  
  def recent_musters_within(muster_ids)
    musters.where("start_time > ?", Time.now - 1.month).where("id IN (?)",muster_ids)
  end
  
  def total_pledged_hours
    pledges.reduce(0){ |sum, p| sum + p.hours}
  end
  
  def total_submitted_hours
    labors.reduce(0){ |sum, p| sum + p.hours}
  end
  
  def total_approved_hours
    labors.select{|l|l.status==Labor::APPROVED}.reduce(0){ |sum, l| sum + l.hours}
  end
  
  def total_stars
    labors.select{|l|l.status==Labor::APPROVED}.reduce(0){ |sum, l| sum + l.hours.to_i * l.average_rating.to_i}
  end
  
  def root_posts
    posts.where(reply_to_post_id:nil)
  end

  def is_private?
    return project_type_id == PRIVATE_PROJECT
  end
  
  def creator
    return User.find_by_id(creator_id)
  end

  def to_s
    name
  end
end
