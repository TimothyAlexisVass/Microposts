require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:test)
    @other_user = users(:test2)
  end

  test "should get signup page" do
    get signup_path
    assert_response :success
  end

  test "should redirect away from edit page when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect away from update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: {
      user: { name: @user.name, email: @user.email }
    }
    assert flash.empty?
    assert_redirected_to root_url
  end

end
