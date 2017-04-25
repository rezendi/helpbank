class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    redirect_to "/"
    @posts = Post.all
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    redirect_to "/"
  end

  # GET /posts/new
  def new
    redirect_to "/"
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
    redirect_to "/"
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        NotificationMailer.send_emails_for(@post)
        format.html { redirect_to (@post.community ? @post.community : @post.project), notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to (@post.community ? @post.community : @post.project), notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    if @post.replies.any?
      @post.content = "<div>(This post deleted by user.)</div>"
      @post.save!
      redirect_to (@post.community ? @post.community : @post.project), notice: "Post content deleted."
    else
      @post.destroy
      respond_to do |format|
        format.html { redirect_to @post.community ? @post.community : @post.project, notice: 'Post was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params[:post][:user_id] = current_user.id
      params.require(:post).permit(:user_id, :project_id, :community_id, :reply_to_post_id, :content)
    end
end
