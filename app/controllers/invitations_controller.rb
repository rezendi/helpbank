class InvitationsController < Devise::InvitationsController
  private

  # this is called when creating invitation
  # should return an instance of resource class
  def invite_resource
    ## skip sending emails on invite
    user = super
    user.invitation_community_id = params[:community_id]
    user.invitation_project_id = params[:project_id]
    user.save
    user
  end

  # this is called when accepting invitation
  # should return an instance of resource class
  def accept_resource
    user = resource_class.accept_invitation!(update_resource_params)
    community = Community.find_by_id(user.invitation_community_id)
    if community and community.community_type_id > Community::APPROVAL_REQUIRED
      inviter = User.find_by_id(user.invited_by_id)
      Membership.create(user_id: user.id, community_id: community.id, role_id: Membership::MEMBER, application_info:"Invited by #{inviter}")
    end
    user
  end
end