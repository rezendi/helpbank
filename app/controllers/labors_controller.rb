class LaborsController < ApplicationController
  before_action :set_labor, only: [:show, :edit, :update, :destroy]
  before_action :set_muster
  before_action :set_project
  before_action :set_user

  # GET /labors
  # GET /labors.json
  def index
    @labors = @muster.labors if @muster.present?
    @labors = @project.labors if @labors.nil? && @project.present? && @user.is_admin_of?(@project)
    @labors = @user.labors if @labors.nil?
  end

  # GET /labors/1
  # GET /labors/1.json
  def show
  end

  # GET /labors/new
  def new
    @labor = Labor.new
  end

  # GET /labors/1/edit
  def edit
  end

  # POST /labors
  # POST /labors.json
  def create
    @labor = Labor.new(labor_params)

    @pledge = @user.first_unfulfilled_pledge_for(@project)
    @labor.pledge_id = @pledge.id if @pledge

    @muster = @labor.user.muster_for(@project, @labor.start_time)
    @labor.muster_id = @muster.id if @muster

    if @project.is_private?
      @pledge = @user.first_unfulfilled_pledge_for(@project)
      if !@pledge
        flash[:notice] = "No previous pledge found. You cannot update unpledged hours for a private project"
        render :new and return
      end
      if @labor.hours > @pledge.hours
        flash[:notice] = "You cannot submit more than your pledged #{@pledge.hours} hours"
        render :new and return
      end
    end

    respond_to do |format|
      if @labor.save
        format.html { redirect_to [@community, @project], notice: 'Labor was successfully created.' }
        format.json { render :show, status: :created, location: @labor }
      else
        format.html { render :new }
        format.json { render json: @labor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /labors/1
  # PATCH/PUT /labors/1.json
  def update
    lparams = labor_params
    respond_to do |format|
      # set pledge and muster correctly
      if @labor.status == Labor::SUBMITTED && lparams[:status].to_i==Labor::APPROVED && current_user.is_admin_of?(@labor.project)

        #does this work match a previous pledge?
        @pledge = @user.first_unfulfilled_pledge_for(@project)
        lparams[:pledge_id] = @pledge.id if @pledge
        
        #does this work match a muster to which the user checked in?
        start_time = DateTime.parse(lparams[:start_time]) if lparams[:start_time]
        @muster = @labor.user.muster_for(@project, start_time ? start_time : @labor.start_time)
        lparams[:muster_id] = @muster.id if @muster
      end
      
      if @project.is_private? && current_user.is_admin_of?(@project)
        stars = params.permit(:rating)[:rating]
        available_stars = current_user.membership_for(@project.community).total_stars
        if stars.to_i * @labor.hours > available_stars
          render :new and return
        end
      end

      if @labor.update(lparams)
        rparam = params.permit(:rating)
        if rparam.has_key?(:rating) and current_user.is_admin_of?(@labor.project)
          stars = rparam[:rating]
          existing = current_user.ratings.where(labor_id:@labor.id)
          existing.last.update_column(:stars, stars) if existing.any? and existing.last.stars != stars.to_i
          Rating.create(stars:stars, labor:@labor, user_id:current_user.id) if existing.empty?
        end
        format.html { redirect_to [@community, @project], notice: 'Labor was successfully updated.' }
        format.json { render :show, status: :ok, location: @labor }
      else
        format.html { render :edit }
        format.json { render json: @labor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /labors/1
  # DELETE /labors/1.json
  def destroy
    redirect_to "/" and return unless current_user.is_admin_of?(@labor.project) or current_user.id==@labor.user.id
    @labor.destroy
    respond_to do |format|
      format.html { redirect_to [@community, @project], notice: 'Labor was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_user
      @user = @labor.user if @labor and @labor.user
      @user = current_user if @user.nil?
    end

    def set_muster
      @muster = @labor.muster if @labor.present?
      @muster = Muster.find_by_id(params[:muster_id]) if @muster.nil?
      if @muster.present?
        redirect_to "/" unless @muster.users.include?(current_user) or current_user.is_admin_of?(@muster.project)
      end
    end
    
    def set_project
      @project = @labor.project if @labor
      @project = @muster.project if @muster
      @project = Project.find_by_id(params[:labor][:project_id]) if @project.nil? and params[:labor]
      @project = Project.find_by_id(params[:project_id]) if @project.nil?
      redirect_to "/" and return if @project and not current_user.is_member_of?(@project)
      @community = @project.community
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_labor
      @labor = Labor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def labor_params
      params[:labor][:user_id] = @user.id
      params[:labor].delete(:status) unless current_user.is_admin_of?(@project)
      params.require(:labor).permit(:user_id, :project_id, :muster_id, :pledge_id, :status, :start_time, :hours, :notes)
    end
end
