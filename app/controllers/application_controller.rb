class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  def check_logged_in
    if current_user.nil?
      flash[:notice] = "Sorry, you must be logged in for that"
      redirect_to "/"
    end
  end

  def check_super_admin
    unless current_user && current_user.is_admin?
      flash[:notice] = "Sorry, you must be a super admin for that"
      redirect_to "/"
    end
  end
  
  def check_community_admin
    if @community.nil?
      flash[:notice] = "No community set"
      redirect_to "/" and return
    end
    if current_user.nil?
      flash[:notice] = "Sorry, you must be logged in and a community admin for that"
      redirect_to community_path(@community) and return
    end
    unless current_user.is_admin_of?(@community)
      flash[:notice] = "Sorry, you must be a community admin for that"
      redirect_to community_path(@community)
    end
  end

  def check_community_member
    @community = @project.community if @community.nil? and @project.present?
    if @community.nil?
      flash[:notice] = "No community set"
      redirect_to "/" and return
    end
    if current_user.nil?
      flash[:notice] = "Sorry, you must be logged in and a community member for that"
      redirect_to community_path(@community) and return
    end
    unless current_user.is_member_of?(@community)
      flash[:notice] = "Sorry, you must be a community member for that"
      redirect_to application_community_path(@community)
    end
  end

  def check_community_access
    @community = @project.community if @community.nil? and @project.present?
    redirect_to "/" and return if @community.nil?
    return true if @community.community_type_id == Community::AUTO_APPROVE
    return check_community_member
  end

  def check_project_admin
    if @project.nil? or @project.community.nil?
      flash[:notice] = "No project set"
      redirect_to "/" and return
    end
    if current_user.nil?
      flash[:notice] = "Sorry, you must be logged in and a community member for that"
      redirect_to community_path(@project.community) and return
    end
    unless current_user.is_admin_of?(@project)
      flash[:notice] = "Sorry, you must be a community admin for that"
      redirect_to community_path(@project.community)
    end
  end
  
  def after_sign_in_path_for(resource)
    "/"
  end

protected

def configure_permitted_parameters
  devise_parameter_sanitizer.permit(:invite, keys: [:community_id, :project_id])
end
end
