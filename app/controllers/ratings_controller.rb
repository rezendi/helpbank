class RatingsController < ApplicationController
  before_action :set_labor
  before_action :set_rating, only: [:show, :edit, :update, :destroy]

  # GET /ratings
  # GET /ratings.json
  def index
    @ratings = @labor.ratings
  end

  # GET /ratings/1
  # GET /ratings/1.json
  def show
  end

  # GET /ratings/new
  def new
    @rating = Rating.new
  end

  # GET /ratings/1/edit
  def edit
  end

  # POST /ratings
  # POST /ratings.json
  def create
    @rating = Rating.new(rating_params)

    respond_to do |format|
      if @rating.save
        format.html { redirect_to [@labor, @rating], notice: 'Labor rating was successfully created.' }
        format.json { render :show, status: :created, location: @rating }
      else
        format.html { render :new }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ratings/1
  # PATCH/PUT /ratings/1.json
  def update
    respond_to do |format|
      if @rating.update(rating_params)
        format.html { redirect_to [@labor, @rating], notice: 'Labor rating was successfully updated.' }
        format.json { render :show, status: :ok, location: @rating }
      else
        format.html { render :edit }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ratings/1
  # DELETE /ratings/1.json
  def destroy
    redirect_to "/" and return unless current_user.is_admin_of?(@rating.labor.project) || current_user==@rating.user
    @rating.destroy
    respond_to do |format|
      format.html { redirect_to labor_url(labor), notice: 'Labor rating was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_labor
      @labor = Labor.find(params[:labor_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_rating
      @rating = Rating.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rating_params
      params[:rating][:labor_id] = @labor.id
      params[:rating][:user_id] = current_user.id
      params.require(:rating).permit(:labor_id, :user_id, :stars, :notes)
    end
end
