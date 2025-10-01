require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def test_index
    assert_response :success if defined?(get)
  end
end

