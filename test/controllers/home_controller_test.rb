require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:one) }

  test "should get index" do
    get root_url
    assert_response :success
  end
end
