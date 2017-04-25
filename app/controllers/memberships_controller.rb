class MembershipsController < ApplicationController
  before_action :set_community
  before_action :set_membership, only: [:show, :edit, :update, :destroy]
  before_action :check_community_admin, only: [:new, :create, :edit, :update, :destroy]
  before_action :check_community_member, only: [:index]

  # GET /members
  # GET /members.json
  def index
    @memberships = @community.memberships
  end

  # GET /members/1
  # GET /members/1.json
  def show
  end

  # GET /members/new
  def new
    @membership = Membership.new
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members
  # POST /members.json
  def create
    @membership = Membership.new(membership_params)

    respond_to do |format|
      if @membership.save
        format.html { redirect_to community_memberships_path(@community), notice: 'Community membership was successfully created.' }
        format.json { render :show, status: :created, location: @membership }
      else
        format.html { render :new }
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    respond_to do |format|
      if @membership.update(membership_params)
        format.html { redirect_to community_memberships_path(@community), notice: 'Community membership was successfully updated.' }
        format.json { render :show, status: :ok, location: @membership }
      else
        format.html { render :edit }
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    @membership.destroy
    respond_to do |format|
      format.html { redirect_to @community, notice: 'Community membership was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_community
      @community = Community.friendly.find(params[:community_id])
    end

    def set_membership
      @membership = Membership.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def membership_params
      params[:membership][:community_id] = @community.id
      throw "Not a superadmin!" if params[:membership][:role_id] == Membership::ADMIN unless check_super_admin
      params.require(:membership).permit(:user_id, :community_id, :role_id, :application_info, :notes)
    end
end
