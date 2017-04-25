require 'test_helper'

class PrivateProjectsTest < ActionDispatch::IntegrationTest
  include FactoryGirl::Syntax::Methods
  
  def setup
    FactoryGirl.find_definitions if FactoryGirl.factories.count == 0
  end
  
  test "private projects" do
    @community = FactoryGirl.create(:community, name: "Test Community", stars_to_create_a_project:50)
    @public_project = FactoryGirl.create(:project, name: "Test Public Project", community_id:@community.id)
    @user1 = FactoryGirl.create(:user, email: "user1@example.com", name: "User One")
    @user2 = FactoryGirl.create(:user, email: "user2@example.com", name: "User Two")
    @user3 = FactoryGirl.create(:user, email: "user3@example.com", name: "User Three")
    FactoryGirl.create(:membership, community_id:@community.id, user_id:@user1.id, role_id:Membership::MEMBER)
    FactoryGirl.create(:membership, community_id:@community.id, user_id:@user2.id, role_id:Membership::MEMBER)
    FactoryGirl.create(:membership, community_id:@community.id, user_id:@user3.id, role_id:Membership::MEMBER)
    FactoryGirl.create(:labor, project_id:@public_project.id, user_id:@user1.id, hours:25, status:Labor::APPROVED)
    FactoryGirl.create(:rating, labor_id:Labor.all.first.id, user_id:@user1.id, stars:4)
    assert_equal 100, @user1.stars_for(@community)
    FactoryGirl.create(:labor, project_id:@public_project.id, user_id:@user2.id, hours:5, status:Labor::APPROVED)
    FactoryGirl.create(:rating, labor_id:Labor.all.last.id, user_id:@user2.id, stars:4)
    assert_equal 20, @user2.stars_for(@community)
    
    sign_in @user2
    post community_projects_path(@community), params: { project: {
      community_id:     @community.id,
      project_type_id:  Project::PRIVATE_PROJECT,
      name:             "Test Failed Private Project",
    }}
    assert_equal 1, Project.count, "Could not create a private project due to insufficient stars"
    
    sign_out
    sign_in @user1
    post community_projects_path(@community), params: { project: {
      community_id:     @community.id,
      project_type_id:  Project::PRIVATE_PROJECT,
      name:             "Test Private Project",
    }}
    assert_equal 2, Project.count, "Created a private project"
    @project = Project.last
    assert_equal @user1.id, @project.creator_id
    
    # test pledge limits - project creator stars / 4
    sign_out
    sign_in @user2
    assert @user2.is_member_of? @project
    post community_project_pledges_path(@community, @project), params: { pledge: {
      hours: 10,
      notes: "Test Private Pledge",
    }}
    assert_equal 10, @project.total_pledged_hours, "Project pledged hours 1"
    assert_equal 10, @user2.first_unfulfilled_pledge_for(@project).hours
    
    sign_out
    sign_in @user3
    post community_project_pledges_path(@community, @project), params: { pledge: {
      hours: 16,
      notes: "Test Failed Private Pledge",
    }}
    assert_equal 10, Project.last.total_pledged_hours, "Project pledged hours 2"
    post community_project_pledges_path(@community, @project), params: { pledge: {
      hours: 15,
      notes: "Test Private Pledge 2",
    }}
    assert_equal 25, Project.last.total_pledged_hours, "Project pledged hours 3"

    # add labor
    sign_out
    sign_in @user2
    post labors_path, params: { labor: {
      project_id: @project.id,
      start_time: Time.now,
      hours:      11,
      notes:      "Test Failed Private Labor",
    }}
    assert_equal 0, Project.last.total_submitted_hours, "Excessive private project labors submitted"
    post labors_path, params: { labor: {
      project_id: @project.id,
      start_time: Time.now,
      hours:      10,
      notes:      "Test Private Labor",
    }}
    assert_equal 10, Project.last.total_submitted_hours, "Submitted labors to private project"
    @labor1 = Labor.last
    assert_equal @project.id, @labor1.project_id
    sign_out
    sign_in @user3
    post labors_path, params: { labor: {
      project_id: @project.id,
      start_time: Time.now,
      hours:      15,
      notes:      "Test Private Labor 2",
    }}
    assert_equal 25, Project.last.total_submitted_hours, "Submitted labors to private project"
    @labor2 = Labor.last

    # approve labors
    assert_equal 0, Project.last.approved_labors.count
    sign_out
    sign_in @user1
    put "/labors/#{@labor1.id}", params: { labor: {
      status: Labor::APPROVED,
    }, rating: 4}
    assert_equal 40, User.first.membership_for(@community).spent_stars, "Spent stars"
    assert_equal 1, Project.last.approved_labors.count, "Approving labors for private project"
    assert_equal 10, Project.last.total_approved_hours, "Correct approved labors for private project"
    assert_equal 60, User.first.stars_for(@community), "Reducing available stars after paid out for private project"
    put "/labors/#{@labor2.id}", params: { labor: {
      status: Labor::APPROVED,
    }, rating: 5}
    assert_equal 10, Project.last.total_approved_hours, "Can't approve too many stars for private project"
    put "/labors/#{@labor2.id}", params: { labor: {
      status: Labor::APPROVED,
    }, rating: 4}
    assert_equal 25, Project.last.total_approved_hours, "Approving more hours"
    assert_equal 0, User.first.stars_for(@community), "Eliminating available stars after paid out for private project"
  end

end