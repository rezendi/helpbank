class CheckInsController < ApplicationController
  before_action :set_user
  before_action :set_muster
  before_action :set_check_in, only: [:show, :edit, :update, :destroy]

  # GET /check_ins
  # GET /check_ins.json
  def index
    @check_ins = @muster ? @muster.check_ins : @user.check_ins
    @check_ins = @check_ins.select{|c|c.user_id == @user.id || current_user.is_admin_of?(c.project)}
  end

  # GET /check_ins/1
  # GET /check_ins/1.json
  def show
  end

  # GET /check_ins/new
  def new
    @check_in = CheckIn.new
    @project = Project.find_by_id(params[:project_id])
  end

  # GET /check_ins/1/edit
  def edit
  end

  # POST /check_ins
  # POST /check_ins.json
  def create
    @check_in = CheckIn.new(check_in_params)

    respond_to do |format|
      if @check_in.save
        format.html { redirect_to user_check_in_path(@user, @check_in), notice: 'Check in was successfully created.' }
        format.json { render :show, status: :created, location: @check_in }
      else
        format.html { render :new }
        format.json { render json: @check_in.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /check_ins/1
  # PATCH/PUT /check_ins/1.json
  def update
    respond_to do |format|
      if @check_in.update(check_in_params)
        format.html { redirect_to user_check_in_path(@user, @check_in), notice: 'Check in was successfully updated.' }
        format.json { render :show, status: :ok, location: @check_in }
      else
        format.html { render :edit }
        format.json { render json: @check_in.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /check_ins/1
  # DELETE /check_ins/1.json
  def destroy
    redirect_to "/" and return if @check_in.user != current_user
    @check_in.destroy
    respond_to do |format|
      format.html { redirect_to user_path(@user), notice: 'Check in was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_user
      @user = User.find_by_id(params[:user_id])
      @user = current_user if !@user
    end

    def set_muster
      @muster = Muster.find_by_id(params[:muster_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_check_in
      @check_in = CheckIn.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def check_in_params
      params[:check_in][:user_id] = @user.id
      params.require(:check_in).permit(:user_id, :project_id, :muster_id, :location_lat, :location_lon, :location)
    end
end
