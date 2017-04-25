class CommunitiesController < ApplicationController
  before_action :set_community, except: [:index, :new, :create]
  before_action :check_community_member, except: [:index, :show, :new, :create, :application, :apply]
  before_action :check_community_admin, only: [:edit, :update, :destroy, :applications, :approve]

  # GET /communities
  # GET /communities.json
  def index
    redirect_to "/"
  end

  # GET /communities/1
  # GET /communities/1.json
  def show
  end
  
  def application
    redirect_to "/" if current_user.nil?
  end
  
  def apply
    existing = Membership.find_by_user_id_and_community_id(current_user.id, @community.id)
    if existing.nil?
      application_info = params[:application_info]
      membership = Membership.create(user_id: current_user.id, community_id: @community.id, role_id: Membership::APPLICANT, application_info:application_info)
      if Community::AUTO_APPROVE == @community.community_type_id
        membership.update_column :role_id, Membership::MEMBER
        flash[:notice] = "Application auto-approved!!"
        redirect_to @community and return
      end
    else
      flash[:notice] = "You already have the status: #{existing.description} for this community."
    end
    redirect_to "/"
  end
  
  def applications
    @pending = @community.pending_applications
    @declined = @community.declined_applications
  end
  
  def approve
    membership = Membership.find(params[:membership_id])
    membership.role_id = Membership::MEMBER
    membership.save!
    redirect_to community_path(@community) and return
  end

  # GET /communities/new
  def new
    @community = Community.new
  end

  # GET /communities/1/edit
  def edit
  end

  # POST /communities
  # POST /communities.json
  def create
    @community = Community.new(community_params)

    respond_to do |format|
      if @community.save
        Membership.create(user_id: current_user. id, role_id: Membership::ADMIN, community_id: @community.id)
        format.html { redirect_to @community, notice: 'Community was successfully created.' }
        format.json { render :show, status: :created, location: @community }
      else
        format.html { render :new }
        format.json { render json: @community.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /communities/1
  # PATCH/PUT /communities/1.json
  def update
    respond_to do |format|
      if @community.update(community_params)
        format.html { redirect_to @community, notice: 'Community was successfully updated.' }
        format.json { render :show, status: :ok, location: @community }
      else
        format.html { render :edit }
        format.json { render json: @community.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /communities/1
  # DELETE /communities/1.json
  def destroy
    @community.destroy
    respond_to do |format|
      format.html { redirect_to communities_url, notice: 'Community was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_community
      @community = Community.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def community_params
      params.require(:community).permit(:name, :description, :notes, :community_type_id, :stars_to_create_a_project)
    end
end
