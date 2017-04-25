class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    redirect_to '/' and return if current_user.nil?
    @users = current_user.is_admin? ? User.all : current_user.communities.map{|c|c.members.map{|m|m.user}}.flatten.uniq
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/1/edit
  def edit
    redirect_to "/" unless @user.id == current_user.id || current_user.is_admin?
    @image = Image.new
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    redirect_to "/" unless @user.id == current_user.id || current_user.is_admin?
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to "/users/#{@user.id}", notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    redirect_to "/" unless @user.id == current_user.id || current_user.is_admin?
    @user.destroy
    respond_to do |format|
      format.html { redirect_to "/", notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :description)
    end
end
