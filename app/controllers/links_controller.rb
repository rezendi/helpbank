class LinksController < ApplicationController
  before_action :check_logged_in
  before_action :set_user
  before_action :set_link, only: [:show, :edit, :update, :destroy]

  # GET /links
  # GET /links.json
  def index
    @links = @muster ? @muster.links : @project ? @project.links : @community ? @community.links : @user.links
    separator = "?"
    @url_suffix = ""
    @url_suffix += separator + "muster_id=#{@muster.id}" if @muster
    separator = "&" if @url_suffix.length > 0
    @url_suffix += separator + "project_id=#{@project.id}" if @project
    separator = "&" if @url_suffix.length > 0
    @url_suffix += separator + "community=#{@community.id}" if @community
  end

  # GET /links/1
  # GET /links/1.json
  def show
  end

  # GET /links/new
  def new
    @link = Link.new
  end

  # GET /links/1/edit
  def edit
  end

  # POST /links
  # POST /links.json
  def create
    params[:link] = {} if params[:link].nil?
    @link = Link.new(link_params)

    respond_to do |format|
      if @link.save
        format.html { redirect_to community_project_path(@link.community, @link.project), notice: 'Image was successfully created.' }
        format.json { render :show, status: :created, location: @link }
      else
        format.html { render :new }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def approve
  end

  # PATCH/PUT /links/1
  # PATCH/PUT /links/1.json
  def update
    redirect_to "/" and return unless current_user.is_admin_of? @link.project
    respond_to do |format|
      if @link.update_column :link_type, params[:link][:link_type]
        format.html { redirect_to [@link.project.community, @link.project], notice: 'Image was successfully updated.' }
        format.json { render :show, status: :ok, location: @link }
      else
        format.html { render :edit }
        format.json { render json: @link.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /links/1
  # DELETE /links/1.json
  def destroy
    redirect_to "/" and return unless current_user.id==@link.user.id || current_user.is_admin_of?(@link.project)
    @project = @link.project
    @link.destroy
    respond_to do |format|
      format.html { redirect_to @project ? community_project_path(@project.community, @project) : "/users/#{@user.id}/edit", notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_user
      @user = current_user

      if params[:link]
        @community = Community.friendly.find(params[:link][:community_id]) if params[:community_id].present?
        redirect_to "/" and return if @community and not @user.is_member_of? @community
  
        @project = Project.find(params[:link][:project_id]) if params[:link][:project_id].present?
        @project = Muster.find(params[:link][:muster_id]).project if @project.nil? and params[:link][:muster_id].present?
      elsif params[:project_id]
        @project = Project.friendly.find(params[:project_id]) if params[:project_id]
      end
      redirect_to "/" and return if @project and not @user.is_member_of? @project
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_link
      @link = Link.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def link_params
      params[:link][:user_id] = @user.id
      params[:link][:project_id] = @project.id if @project
      params[:link][:community_id] = @project.community_id if @project and params[:link][:community_id].blank?
      params.require(:link).permit(:user_id, :community_id, :project_id, :muster_id, :sequence, :url, :name, :description)
    end
end
