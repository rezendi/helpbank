class HomeController < ApplicationController
  def index
    @communities = Community.all
  end
  
  def about
  end

  def search
    @communities = Community.where("name LIKE ?", "%#{params[:q]}%")
    @projects = Project.where("name LIKE ?", "%#{params[:q]}%")
  end
end
