class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :set_community
  before_action :check_community_access, only: [:index, :show]
  before_action :check_project_admin, only: [:edit, :update, :destroy]
  before_action :check_can_create_project, only: [:new, :create]

  # GET /projects
  # GET /projects.json
  def index
    redirect_to "/"
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    create_params = project_params
    if current_user.is_admin_of? @community
      create_params[:project_type_id] = Project::COMMUNITY_PROJECT
    elsif check_can_create_project
      create_params[:project_type_id] = Project::PRIVATE_PROJECT
    else
      redirect_to community_projects_path(@community) and return
    end
    @project = Project.new(create_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to community_projects_path(@community), notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      update_params = project_params
      update_params.delete(:project_type_id)
      if @project.update(update_params)
        format.html { redirect_to community_projects_path(@community), notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to community_path(@community), notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def check_can_create_project
      current_user.can_create_private_project_for?(@community)
    end
  
    def set_community
      @community = @project.community if @project
      @community = Community.friendly.find(params[:community_id]) if @community.nil?
      @community = Community.find_by_id(params[:project][:community_id]) if @community.nil? and params[:project].present?
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params[:project][:creator_id] = current_user.id
      params.require(:project).permit(:community_id, :project_type_id, :creator_id, :name, :objective, :call_to_action,
                                      :description, :target_date, :original_target_date, :video_url, :notes)
    end
end
