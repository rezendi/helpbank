class Community < ApplicationRecord
  has_many :memberships
  has_many :projects
  has_many :posts
  has_many :links
  include FriendlyId
  friendly_id :name, :use => :slugged
  
  APPROVAL_REQUIRED = 0
  AUTO_APPROVE_INVITEES = 1
  AUTO_APPROVE = 2

  def admins
    memberships.where("role_id = ?", Membership::ADMIN)
  end

  def to_s
    name
  end
  
  def members_and_admins
    Membership.where(community_id: self.id).where("role_id IN (?)", [Membership::MEMBER, Membership::ADMIN])
  end

  def pending_applications
    Membership.where(community_id: self.id).where(role_id: Membership::APPLICANT)
  end

  def declined_applications
    Membership.where(community_id: self.id).where(role_id: Membership::DECLINED)
  end
  
  def root_posts
    posts.where(reply_to_post_id:nil)
  end
end
