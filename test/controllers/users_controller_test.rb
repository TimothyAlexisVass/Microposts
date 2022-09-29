require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @testuser = users(:test)
    @testuser_2 = users(:test2)
  end

  test "should get signup page" do
    get signup_path
    assert_response :success
  end

  test "should redirect away from edit page when logged in as wrong user" do
    log_in_as(@testuser_2)
    get edit_user_path(@testuser)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect away from update when logged in as wrong user" do
    log_in_as(@testuser_2)
    patch user_path(@testuser), params: {
      user: { name: @testuser.name, email: @testuser.email }
    }
    assert flash.empty?
    assert_redirected_to root_url
  end

end
