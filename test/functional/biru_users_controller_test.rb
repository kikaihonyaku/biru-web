require 'test_helper'

class BiruUsersControllerTest < ActionController::TestCase
  setup do
    @biru_user = biru_users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:biru_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create biru_user" do
    assert_difference('BiruUser.count') do
      post :create, biru_user: { code: @biru_user.code, name: @biru_user.name, password: @biru_user.password }
    end

    assert_redirected_to biru_user_path(assigns(:biru_user))
  end

  test "should show biru_user" do
    get :show, id: @biru_user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @biru_user
    assert_response :success
  end

  test "should update biru_user" do
    put :update, id: @biru_user, biru_user: { code: @biru_user.code, name: @biru_user.name, password: @biru_user.password }
    assert_redirected_to biru_user_path(assigns(:biru_user))
  end

  test "should destroy biru_user" do
    assert_difference('BiruUser.count', -1) do
      delete :destroy, id: @biru_user
    end

    assert_redirected_to biru_users_path
  end
end
