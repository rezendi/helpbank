require 'test_helper'

class WholeShebangTest < ActionDispatch::IntegrationTest
  include FactoryGirl::Syntax::Methods
  
  def setup
    FactoryGirl.find_definitions if FactoryGirl.factories.count == 0
  end

  test "the whole shebang" do
    @admin = FactoryGirl.create(:user, email: "admin@example.com", name: "Admin User")
    sign_in @admin
    assert response.body.include? "Signed in successfully"
    
    # create a community
    communities = Community.count
    post communities_path, params: { community: {
      community_type_id: 1,
      name:             "Test Community",
      description:      "Test Description",
      notes:            "Test Notes",
    }}
    assert Community.count == communities+1
    @community = Community.last
    assert_equal "Test Community", @community.name, "Community name"
    
    # create a project
    projects = Project.count
    post community_projects_path(@community), params: { project: {
      community_id:     @community.id,
      project_type_id:  Project::COMMUNITY_PROJECT,
      name:             "Test Project",
      objective:        "Test Objective",
      description:      "Test Description",
      call_to_action:   "Test Call To Action",
      target_date:       Date.parse("22/11/2017").to_s,
    }}
    assert Project.count == projects + 1
    @project = Project.last
    assert_equal "Test Project", @project.name, "Project name"
    assert_equal Date.parse("22/11/2017"), @project.target_date, "Project target date"
    
    # create a muster
    musters = Muster.count
    post community_project_musters_path(@community, @project), params: { muster: {
      project_id:   @project.id,
      description:  "Test Muster",
      location:     "Test Location",
      location_lat: 51.1,
      location_lon: -102.2,
      start_time:   Time.now,
      end_time:     Time.now + 3.hours,
    }}
    assert Muster.count == musters + 1
    @muster = Muster.last
    assert_equal "Test Muster", @muster.description, "Muster description"
    assert_equal 51.1, @muster.location_lat, "Muster lat"
    assert_equal(-102.2, @muster.location_lon, "Muster lon")
    
    sign_out
    @user = FactoryGirl.create(:user, email: "user@example.com", name: "Test User")
    sign_in @user
    
    # apply to community
    
    get "/communities/#{@community.id}/application"
    assert_response :success

    memberships = Membership.count
    post "/communities/#{@community.id}/apply", params: { "application_info" => "Howdy!"}
    assert Membership.count == memberships + 1
    @membership = Membership.last
    assert_equal Membership::APPLICANT, @membership.role_id, "Membership role - submitted"
    assert_equal "Howdy!", @membership.application_info, "Membership application info"
    
    # approve application
    
    sign_out
    sign_in @admin
    
    get "/communities/#{@community.id}/applications"
    assert_response :success

    post "/communities/#{@community.id}/approve", params: { membership_id: @membership.id}
    @membership = Membership.last
    assert_equal Membership::MEMBER, @membership.role_id, "Membership role - approved"
    
    sign_out
    sign_in @user
    
    # add a pledge
    
    pledges = Pledge.count
    post community_project_pledges_path(@community, @project), params: { pledge: {
      hours: 3,
      notes: "Test Pledge",
    }}
    assert Pledge.count == pledges + 1
    @pledge = Pledge.last
    assert_equal 3, @pledge.hours, "Pledge hours"
    assert_equal "Test Pledge", @pledge.notes, "Pledge notes"
    
    # check in to muster
    check_ins = CheckIn.count
    post user_check_ins_path(@user), params: { check_in: {
      project_id: @project.id,
      muster_id: @muster.id,
      location_lat: 51.1,
      location_lon: -102.2,
    }}
    assert CheckIn.count == check_ins + 1
    @check_in = CheckIn.last
    assert_equal 51.1, @check_in.location_lat, "Check in lat"
    assert_equal(-102.2, @check_in.location_lon, "Check in lon")
    
    # add a labor
    labor_time = Time.now
    labors = Labor.count
    post labors_path, params: { labor: {
      project_id: @project.id,
      start_time: labor_time,
      hours:      3,
      notes:      "Test Notes",
    }}
    assert Labor.count == labors + 1
    @labor = Labor.last
    assert_equal 3, @labor.hours, "Labor hours"
    assert_equal "Test Notes", @labor.notes, "Labor notes"
    assert_equal @project.id, @labor.project_id, "Labor project"
    assert_equal labor_time.to_i, @labor.start_time.to_i, "Labor start time"
    
    sign_out
    sign_in @admin
    
    # approve labor
    
    put "/labors/#{@labor.id}", params: { labor: {
      status: Labor::APPROVED,
    }, rating: 3}
    @labor = Labor.last
    assert_equal @pledge.id, @labor.pledge_id, "Labor pledge assignment"
    assert_equal @muster.id, @labor.muster_id, "Labor muster assignment"
    assert_equal 1, @labor.ratings.count, "Labor ratings count"
    assert_equal 3, @labor.ratings.first.stars, "Labor rating stars"
    
    # add another user's labor
    sign_out
    @user2 = FactoryGirl.create(:user, email: "user2@example.com", name: "Test User 2")
    sign_in @user2
    post "/communities/#{@community.id}/apply", params: { "application_info" => "Howdy 2!"}
    @membership = Membership.last
    
    sign_out
    sign_in @admin
    post "/communities/#{@community.id}/approve", params: { membership_id: @membership.id}
    
    sign_out
    sign_in @user2
    post community_project_pledges_path(@community, @project), params: { pledge: {
      hours: 2,
      notes: "Test Pledge 2",
    }}
    post user_check_ins_path(@user2), params: { check_in: {
      project_id: @project.id,
      muster_id: @muster.id,
      location_lat: 51.1,
      location_lon: -102.2,
    }}
    labor_time = Time.now
    post labors_path, params: { labor: {
      project_id: @project.id,
      start_time: labor_time,
      hours:      1,
      notes:      "Test Notes 2",
    }}
    @labor = Labor.last

    sign_out
    sign_in @admin
    put "/labors/#{@labor.id}", params: { labor: {
      status: Labor::APPROVED
    }, rating: 3}
    assert_equal 1, @labor.ratings.count, "Labor ratings"
    assert_equal true, @muster.has_unrated_labors(@user2), "User asked to rate others' rating"

    sign_out
    sign_in @user
    
    assert_equal true, @muster.has_unrated_labors(@user), "User asked to rate others' rating"

    get "/"
    assert response.body.include? "Rate Labors"
    
    get "/labors?muster_id=#{@muster.id}"
    assert response.body.include? "Test"
    
    post "/labors/#{@labor.id}/ratings", params: { rating: {
      stars: 4
    }}
    assert @labor.ratings.count == 2
    
    get "/labors/#{@labor.id}/ratings"
    assert response.body.include? "****"
    assert response.body.include? "3.5 stars"
  end
end