class PledgesController < ApplicationController
  before_action :set_project
  before_action :set_user
  before_action :set_pledge, only: [:show, :edit, :update, :destroy]

  # GET /pledges
  # GET /pledges.json
  def index
    @pledges = Pledge.all
  end

  # GET /pledges/1
  # GET /pledges/1.json
  def show
  end

  # GET /pledges/new
  def new
    @pledge = Pledge.new
  end

  # GET /pledges/1/edit
  def edit
  end

  # POST /pledges
  # POST /pledges.json
  def create
    @pledge = Pledge.new(pledge_params)
    if @project.is_private? && @project.creator.stars_for(@community) < (@project.total_pledged_hours + @pledge.hours) * 4
      available_pledge_hours = @project.creator.stars_for(@community) / 4 - @project.total_pledged_hours
      flash[:notice] = "You can only pledge #{available_pledge_hours} to this private project."
      render :new and return
    end

    respond_to do |format|
      if @pledge.save
        format.html { redirect_to [@community, @project, @pledge], notice: 'Pledge was successfully created.' }
        format.json { render :show, status: :created, location: @pledge }
      else
        format.html { render :new }
        format.json { render json: @pledge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pledges/1
  # PATCH/PUT /pledges/1.json
  def update
    respond_to do |format|
      if @pledge.update(pledge_params)
        format.html { redirect_to [@community, @project, @pledge], notice: 'Pledge was successfully updated.' }
        format.json { render :show, status: :ok, location: @pledge }
      else
        format.html { render :edit }
        format.json { render json: @pledge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pledges/1
  # DELETE /pledges/1.json
  def destroy
    @pledge.destroy
    respond_to do |format|
      format.html { redirect_to [@community, @project], notice: 'Pledge was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = current_user.is_admin_of?(@project) ? User.find_by_id(params[:user_id]) : current_user
      @user = @user ? @user : current_user
    end

    def set_project
      @project = Project.friendly.find(params[:project_id])
      redirect_to "/" and return unless current_user.is_member_of?(@project)
      @community = @project.community
    end

    def set_pledge
      @pledge = Pledge.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pledge_params
      params[:pledge][:user_id] = @user.id
      params[:pledge][:project_id] = @project.id
      params.require(:pledge).permit(:user_id, :project_id, :hours, :notes)
    end
end
