require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:test1)
    @user2 = users(:test4)
    log_in_as(@user)
  end
  test "following page" do
    get following_user_path(@user)
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |followed|
      assert_select "a[href=?]", user_path(followed)
    end
  end
  
  test "followers page" do
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |follower|
      assert_select "a[href=?]", user_path(follower)
    end
  end

  test "should follow a user the standard way" do
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: { followed_id: @user2.id }
    end
  end

  test "should follow a user with Ajax" do
    assert_difference '@user.following.count', 1 do
      post relationships_path, xhr: true, params: { followed_id: @user2.id }
    end
  end

  test "should unfollow a user the standard way" do
    @user.follow(@user2)
    relationship = @user.following_a_user.find_by(followed_id: @user2.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship)
    end
  end

  test "should unfollow a user with Ajax" do
    @user.follow(@user2)
    relationship = @user.following_a_user.find_by(followed_id: @user2.id)
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship), xhr: true
    end
  end
end
