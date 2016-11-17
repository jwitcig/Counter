require 'test_helper'

class ProjectControllerTest < ActionDispatch::IntegrationTest
  test "should get list" do
    get project_list_url
    assert_response :success
  end

end
