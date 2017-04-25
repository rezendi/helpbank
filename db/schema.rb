# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170328062743) do

  create_table "check_ins", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "muster_id"
    t.integer  "check_in_type"
    t.decimal  "location_lat"
    t.decimal  "location_lon"
    t.string   "location"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["muster_id"], name: "index_check_ins_on_muster_id"
    t.index ["project_id"], name: "index_check_ins_on_project_id"
    t.index ["user_id"], name: "index_check_ins_on_user_id"
  end

  create_table "communities", force: :cascade do |t|
    t.integer  "community_type_id"
    t.integer  "stars_to_create_a_project"
    t.string   "name"
    t.string   "slug"
    t.text     "description"
    t.text     "notes"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["community_type_id"], name: "index_communities_on_community_type_id"
    t.index ["name"], name: "index_communities_on_name", unique: true
  end

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "accesstoken"
    t.string   "refreshtoken"
    t.string   "uid"
    t.string   "name"
    t.string   "email"
    t.string   "nickname"
    t.string   "image"
    t.string   "phone"
    t.string   "urls"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "community_id"
    t.integer  "project_id"
    t.integer  "muster_id"
    t.integer  "sequence"
    t.integer  "image_type"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.index ["community_id"], name: "index_images_on_community_id"
    t.index ["muster_id"], name: "index_images_on_muster_id"
    t.index ["project_id"], name: "index_images_on_project_id"
    t.index ["user_id"], name: "index_images_on_user_id"
  end

  create_table "labors", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "muster_id"
    t.integer  "pledge_id"
    t.integer  "status",     default: 0
    t.datetime "start_time"
    t.integer  "hours"
    t.text     "notes"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["muster_id"], name: "index_labors_on_muster_id"
    t.index ["pledge_id"], name: "index_labors_on_pledge_id"
    t.index ["project_id"], name: "index_labors_on_project_id"
    t.index ["user_id"], name: "index_labors_on_user_id"
  end

  create_table "links", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "community_id"
    t.integer  "project_id"
    t.integer  "muster_id"
    t.integer  "sequence"
    t.string   "url"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["community_id"], name: "index_links_on_community_id"
    t.index ["muster_id"], name: "index_links_on_muster_id"
    t.index ["project_id"], name: "index_links_on_project_id"
    t.index ["user_id"], name: "index_links_on_user_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "community_id"
    t.integer  "project_id"
    t.integer  "role_id"
    t.text     "application_info"
    t.text     "notes"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["community_id"], name: "index_memberships_on_community_id"
    t.index ["project_id"], name: "index_memberships_on_project_id"
    t.index ["role_id"], name: "index_memberships_on_role_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "musters", force: :cascade do |t|
    t.integer  "project_id"
    t.string   "location"
    t.decimal  "location_lat"
    t.decimal  "location_lon"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "description"
    t.text     "notes"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["project_id"], name: "index_musters_on_project_id"
  end

  create_table "pledges", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "hours"
    t.text     "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_pledges_on_project_id"
    t.index ["user_id"], name: "index_pledges_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "community_id"
    t.integer  "project_id"
    t.integer  "pledge_id"
    t.integer  "muster_id"
    t.integer  "update_id"
    t.integer  "phase_id"
    t.integer  "image_id"
    t.integer  "reply_to_post_id"
    t.text     "content"
    t.text     "notes"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["community_id"], name: "index_posts_on_community_id"
    t.index ["image_id"], name: "index_posts_on_image_id"
    t.index ["muster_id"], name: "index_posts_on_muster_id"
    t.index ["pledge_id"], name: "index_posts_on_pledge_id"
    t.index ["project_id"], name: "index_posts_on_project_id"
    t.index ["reply_to_post_id"], name: "index_posts_on_reply_to_post_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.integer  "community_id"
    t.integer  "project_type_id"
    t.integer  "creator_id"
    t.string   "name"
    t.string   "slug"
    t.string   "objective"
    t.string   "call_to_action"
    t.text     "description"
    t.date     "target_date"
    t.date     "original_target_date"
    t.string   "video_url"
    t.text     "notes"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["community_id"], name: "index_projects_on_community_id"
    t.index ["name"], name: "index_projects_on_name", unique: true
    t.index ["project_type_id"], name: "index_projects_on_project_type_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.integer  "labor_id"
    t.integer  "user_id"
    t.integer  "status",     default: 0
    t.integer  "stars"
    t.text     "notes"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["labor_id"], name: "index_ratings_on_labor_id"
    t.index ["status"], name: "index_ratings_on_status"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                   default: "", null: false
    t.string   "encrypted_password",      default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "role_id"
    t.string   "name"
    t.text     "description"
    t.text     "notes"
    t.date     "date_of_birth"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invitation_community_id"
    t.integer  "invitation_project_id"
    t.string   "invited_by_type"
    t.integer  "invited_by_id"
    t.integer  "invitations_count",       default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
