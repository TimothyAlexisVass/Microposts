require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @testuser = users(:test1)
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

  test "should redirect index to log in for guests" do
    get users_path
    assert_redirected_to login_url
  end

  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@testuser_2)
    assert_not @testuser_2.admin?
    patch user_path(@testuser_2), params: { user: { password: 'password', password_confirmation: 'password', admin: true } }   
    assert_not @testuser_2.admin?
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@testuser)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@testuser_2)
    assert_no_difference 'User.count' do
      delete user_path(@testuser)
    end
    assert_redirected_to root_url
  end
end
