require 'test_helper'

class VariousOtherTest < ActionDispatch::IntegrationTest
  include FactoryGirl::Syntax::Methods
  
  def setup
    FactoryGirl.find_definitions if FactoryGirl.factories.count == 0
  end
  
  test "invitations and approvals" do
    @user1 = FactoryGirl.create(:user, email: "user1@example.com", name: "User One")
    @user2 = FactoryGirl.create(:user, email: "user2@example.com", name: "User Two")

    @auto_community = FactoryGirl.create(:community, name: "Test Auto Approval Community", community_type_id:Community::AUTO_APPROVE)
    sign_in @user1
    post "/communities/#{@auto_community.id}/apply", params: { "application_info" => "Howdy!"}
    assert @user1.is_member_of?(@auto_community)

    @auto_invites_community = FactoryGirl.create(:community, name: "Test Auto Approve Invites Community", community_type_id:Community::AUTO_APPROVE_INVITEES)
    sign_in @user2
    post "/communities/#{@auto_invites_community.id}/apply", params: { "application_info" => "Howdy!"}
    assert !@user2.is_member_of?(@auto_invites_community)
    @user1.memberships.first.update_column :community_id, @auto_invites_community.id
    sign_in @user1
    post "/users/invitation", params: { community_id: @auto_invites_community.id, user: { email: "user3@example.com"} }
    assert_equal @auto_invites_community.id, User.last.invitation_community_id
    sign_out
    @user4 = User.invite!({:email => "user4@example.com", :name => "John Doe", :skip_invitation => true}, )
    get accept_user_invitation_url(:invitation_token => @user4.raw_invitation_token)
    raw_token = response.body.split('" name="user[invitation_token]')[0].split('"').last
    assert raw_token.length > 0
    assert_equal "user4@example.com", User.last.email

    # FIXME: devise mapping bug
    # put "/users/invitation", params: { user: { invitation_token: raw_token, password: "password", password_confirmation: "password"} }
    # assert Membership::MEMBER, User.last.memberships.first.role_id

    @approval_community = FactoryGirl.create(:community, name: "Test Approval Only Community", community_type_id:Community::APPROVAL_REQUIRED)
    sign_in @user2
    post "/communities/#{@approval_community.id}/apply", params: { "application_info" => "Howdy!"}
    assert !@user2.is_member_of?(@approval_community)

  end
  
  test "forums and notifications" do
    @community = FactoryGirl.create(:community, name: "Test Community")
    @project = FactoryGirl.create(:project, name: "Test Project", community_id:@community.id)
    @user1 = FactoryGirl.create(:user, email: "user1@example.com", name: "User One")
    @user2 = FactoryGirl.create(:user, email: "user2@example.com", name: "User Two")
    @user3 = FactoryGirl.create(:user, email: "user3@example.com", name: "User Three")
    sign_in @user1
    post "/posts", params: { post: { community_id:@community.id, content: "This is only a test"} }
    assert_equal Post.count, 1
    @post = Post.last
    assert_equal @user1.id, Post.last.user_id
    assert_equal @community.id, Post.last.community_id
    assert_equal nil, Post.last.project_id
    post "/posts", params: { post: { community_id:@community.id, project_id:@project.id, content: "This too is only a test"} }
    assert_equal Post.count, 2
    @post = Post.last
    assert_equal @user1.id, Post.last.user_id
    assert_equal @community.id, Post.last.community_id
    assert_equal @project.id, Post.last.project_id
    sign_out
    sign_in @user2
    post "/posts", params: { post: { community_id:@community.id, project_id:@project.id, reply_to_post_id:@post.id, content: "This is a reply"} }
    assert_equal @user2.id, Post.last.user_id
    assert_equal @community.id, Post.last.community_id
    assert_equal @project.id, Post.last.project_id
    assert_equal @post.id, Post.last.reply_to_post_id
    sign_out
    sign_in @user3
    post "/posts", params: { post: { community_id:@community.id, project_id:@project.id, reply_to_post_id:@post.id, content: "This too is a reply"} }
    
  end
  
  test "some basic index and show pages" do
    @community = FactoryGirl.create(:community, name: "Test Community", community_type_id:Community::AUTO_APPROVE)
    @project = FactoryGirl.create(:project, name: "Test Project", community_id:@community.id)
    @user = FactoryGirl.create(:user, email: "user1@example.com", name: "User One")
    sign_in @user
    post "/communities/#{@community.id}/apply", params: { "application_info" => "Howdy!"}
    
    get "/"
    assert_response :success
    get "/communities/#{@community.slug}"
    assert_response :success
    get "/communities/#{@community.slug}/memberships"
    assert_response :success
    get "/communities/#{@community.slug}/projects/#{@project.slug}"
    assert_response :success
    get "/communities/#{@community.slug}/projects/#{@project.slug}/pledges"
    assert_response :success
    get "/communities/#{@community.slug}/projects/#{@project.slug}/musters"
    assert_response :success
    get "/users/#{@user.id}"
    assert_response :success
    get "/users/#{@user.id}/check_ins"
    assert_response :success
  end
end