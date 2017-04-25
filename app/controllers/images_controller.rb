class ImagesController < ApplicationController
  before_action :check_logged_in
  before_action :set_user
  before_action :set_image, only: [:show, :edit, :update, :destroy]

  # GET /images
  # GET /images.json
  def index
    if @project.present?
      @images = @muster ? @muster.images : @project.approved_images
    else
      @images = @user.images
    end
  end

  # GET /images/1
  # GET /images/1.json
  def show
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images
  # POST /images.json
  def create
    params[:image] = {} if params[:image].nil?
    params[:image][:image_type] = Image::SUBMITTED
    @image = Image.new(image_params)

    respond_to do |format|
      if @image.save
        format.html { redirect_to (@image.project ? community_project_path(@image.project.community, @image.project) : @image.user), notice: 'Image was successfully created.' }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def approve
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    redirect_to "/" and return unless current_user.is_admin_of? @image.project
    respond_to do |format|
      if @image.update_column :image_type, params[:image][:image_type]
        format.html { redirect_to (@image.project ? community_project_path(@image.project.community, @image.project) : @image.user), notice: 'Image was successfully updated.' }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    redirect_to "/" and return unless current_user.id==@image.user.id || current_user.is_admin_of?(@image.project)
    @project = @image.project
    @image.destroy
    respond_to do |format|
      format.html { redirect_to @project ? [@project.community, @project] : "/users/#{@user.id}/edit", notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_user
      @user = current_user

      if params[:image]
        @project = Project.find(params[:image][:project_id]) if params[:image][:project_id].present?
        @muster = Muster.find(params[:image][:muster_id]) if params[:image][:muster_id].present?
        @project = @muster.project if @muster.present?
        @community = @project.community if @project.present?
        @community = Community.friendly.find(params[:image][:community_id]) if params[:community_id].present?
        redirect_to "/" and return if @community and not @user.is_member_of? @community
      elsif params[:project_id]
        @project = Project.friendly.find(params[:project_id]) if params[:project_id]
      end
      redirect_to "/" and return if @project and not @user.is_member_of? @project
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_params
      params[:image][:file] = params[:file]
      params[:image][:user_id] = @user.id
      params[:image][:project_id] = @project.id if @project
      params[:image][:community_id] = @community.id if @community and params[:image][:community_id].blank?
      params[:image][:image_type] = Image::APPROVED if current_user.is_admin_of?(@community)
      params.require(:image).permit(:user_id, :community_id, :project_id, :muster_id, :sequence, :image_type, :name, :description, :file)
    end
end
