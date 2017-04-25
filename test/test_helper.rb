ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  def sign_in(user)
    post user_session_path, params: {"user[email]"    => user.email, "user[password]" => user.password }
    follow_redirect!
  end
  
  def sign_out
    get destroy_user_session_path
    follow_redirect!
  end

  # Add more helper methods to be used by all tests here...
end
