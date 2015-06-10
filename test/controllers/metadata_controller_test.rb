require 'test_helper'

class MetadataControllerTest < ActionController::TestCase
  setup do
    @metadatum = metadata(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:metadata)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create metadatum" do
    assert_difference('Metadatum.count') do
      post :create, metadatum: { manifest: @metadatum.manifest, mets: @metadatum.mets }
    end

    assert_redirected_to metadatum_path(assigns(:metadatum))
  end

  test "should show metadatum" do
    get :show, id: @metadatum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @metadatum
    assert_response :success
  end

  test "should update metadatum" do
    patch :update, id: @metadatum, metadatum: { manifest: @metadatum.manifest, mets: @metadatum.mets }
    assert_redirected_to metadatum_path(assigns(:metadatum))
  end

  test "should destroy metadatum" do
    assert_difference('Metadatum.count', -1) do
      delete :destroy, id: @metadatum
    end

    assert_redirected_to metadata_path
  end
end
