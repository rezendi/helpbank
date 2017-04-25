class MustersController < ApplicationController
  before_action :set_muster, only: [:show, :edit, :update, :destroy]
  before_action :set_project
  before_action :check_project_admin, only: [:new, :create, :edit, :update, :destroy]

  # GET /musters
  # GET /musters.json
  def index
    @musters = Muster.all
  end

  # GET /musters/1
  # GET /musters/1.json
  def show
  end

  # GET /musters/new
  def new
    @muster = Muster.new
  end

  # GET /musters/1/edit
  def edit
  end

  # POST /musters
  # POST /musters.json
  def create
    @muster = Muster.new(muster_params)

    respond_to do |format|
      if @muster.save
        format.html { redirect_to [@community, @project, @muster], notice: 'Muster was successfully created.' }
        format.json { render :show, status: :created, location: @muster }
      else
        format.html { render :new }
        format.json { render json: @muster.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /musters/1
  # PATCH/PUT /musters/1.json
  def update
    respond_to do |format|
      if @muster.update(muster_params)
        format.html { redirect_to [@community, @project, @muster], notice: 'Muster was successfully updated.' }
        format.json { render :show, status: :ok, location: @muster }
      else
        format.html { render :edit }
        format.json { render json: @muster.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /musters/1
  # DELETE /musters/1.json
  def destroy
    @muster.destroy
    respond_to do |format|
      format.html { redirect_to [@project.community, @project], notice: 'Muster was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_project
      @project = @muster.project if @muster
      @project = Project.friendly.find(params[:project_id]) if @project.nil?
      @community = @project.community
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_muster
      @muster = Muster.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def muster_params
      params[:muster][:project_id] = @project.id
      params.require(:muster).permit(:project_id, :location, :location_lat, :location_lon, :description, :notes, :start_time, :end_time)
    end
end
