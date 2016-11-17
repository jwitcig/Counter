require 'test_helper'

class StatsControllerTest < ActionDispatch::IntegrationTest
  test "should get file" do
    get stats_file_url
    assert_response :success
  end

  test "should get files" do
    get stats_files_url
    assert_response :success
  end

end
