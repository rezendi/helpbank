class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  def check_logged_in
    redirect_to "/" if current_user.nil?
  end

  def check_super_admin
    redirect_to "/" unless current_user && current_user.is_admin?
  end
  
  def check_community_admin
    redirect_to "/" and return if @community.nil?
    redirect_to community_path(@community) and return if current_user.nil?
    redirect_to community_path(@community) unless current_user.is_admin_of?(@community)
  end

  def check_community_member
    @community = @project.community if @community.nil? and @project.present?
    redirect_to "/" and return if @community.nil?
    redirect_to application_community_path(@community) and return if current_user.nil?
    redirect_to application_community_path(@community) unless current_user.is_member_of?(@community)
  end

  def check_community_access
    @community = @project.community if @community.nil? and @project.present?
    redirect_to "/" and return if @community.nil?
    return true if @community.community_type_id == Community::AUTO_APPROVE
    return check_community_member
  end

  def check_project_admin
    redirect_to "/" and return if @project.nil? or @project.community.nil?
    redirect_to community_path(@project.community) and return if @project.nil? || current_user.nil?
    redirect_to community_path(@project.community) unless current_user.is_admin_of?(@project)
  end
  
  def after_sign_in_path_for(resource)
    "/"
  end

protected

def configure_permitted_parameters
  devise_parameter_sanitizer.permit(:invite, keys: [:community_id, :project_id])
end
end
