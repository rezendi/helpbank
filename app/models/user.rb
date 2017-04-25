class User < ApplicationRecord
  devise :invitable, :omniauthable, :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable
         
  has_many :identities
  has_many :memberships
  has_many :communities, :through => :memberships
  has_many :ratings
  has_many :pledges
  has_many :labors
  has_many :musters
  has_many :check_ins
  has_many :images
  has_many :posts
  has_many :links
  
  # for now
  def is_admin?
    role_id == -1
  end
  
  def to_s
    name ? name : email
  end
  
  def member_communities
    return Community.where("id IN (?)", memberships.where("role_id >= 0").map{|m|m.community_id})
  end

  def projects
    return member_communities.map{|c|c.projects}.flatten
  end
  
  def private_projects_for(community)
    return community.projects.where(creator_id:id)
  end
  
  def is_member_of?(c_or_p)
    return false if c_or_p.nil?
    if c_or_p.instance_of? Project
      project = c_or_p
      return is_admin? || memberships.select{|m|m.role_id >= 0}.map{|m|m.community_id}.include?(project.community_id)
    else
      community = c_or_p
      return is_admin? || memberships.select{|m|m.role_id >= 0}.map{|m|m.community_id}.include?(community.id)
    end
  end

  def is_admin_of?(c_or_p)
    return false if c_or_p.nil?
    if c_or_p.instance_of? Project
      project = c_or_p
      return is_admin? || project.creator_id == id || memberships.select{|m|m.role_id == Membership::ADMIN}.map{|m|m.community_id}.include?(project.community_id)
    else
      community = c_or_p
      return is_admin? || memberships.select{|m|m.role_id == Membership::ADMIN}.map{|m|m.community_id}.include?(community.id)
    end
  end

  def membership_for(c_or_p)
    return nil if c_or_p.nil?
    if c_or_p.instance_of? Project
      project = c_or_p
      return memberships.find{|m|m.community_id == project.community.id}
    else
      community = c_or_p
      return memberships.find{|m|m.community_id == community.id}
    end
    nil
  end

  def submitted_labors
    labors.where(status:Labor::SUBMITTED)
  end

  def approved_labors
    labors.where(status:Labor::APPROVED)
  end
  
  def first_unfulfilled_pledge_for(project)
    project_pledges = pledges.where(project_id: project.id)
    total_pledge_hours = project_pledges.reduce(0){ |sum, i| sum + i.hours}
    labors = approved_labors.where(project_id: project.id)
    total_labor_hours = labors.reduce(0){ |sum, i| sum + i.hours}
    if total_pledge_hours > total_labor_hours
      pledges.where(project_id: project.id).each do |pledge|
        total_labor_hours -= pledge.hours
        return pledge if total_labor_hours < 0
      end
    end
    nil
  end
      
  def stars_for(community)
    awarded_stars = approved_labors.select{|l|l.project.community_id == community.id}.reduce(0){|sum, l| sum = sum + l.average_rating * l.hours}
    awarded_stars - membership_for(community).spent_stars.to_i
  end
  
  def hours_for(community)
    approved_labors.select{|l|l.project.community_id == community.id}.reduce(0){|sum, l| sum = sum + l.hours}
  end
  
  def can_create_private_project_for?(community)
    return stars_for(community) > community.stars_to_create_a_project.to_i
  end

  def personal_images
    images.where(community_id:nil)
  end
  
  def muster_for(project, start_time)
    #was there a muster at this start time?
    musters = project.musters.where("start_time <= ?", start_time).where("end_time >= ?", start_time)
    
    #did this user check in to it?
    for muster in musters
      cis = check_ins.where("created_at >= ?", muster.start_time).where("created_at <= ?", muster.end_time)
      return muster if cis.any?
    end
    nil
  end
      

end
