require 'test_helper'

# TODO: Support SQLite for Sequel when Rails.env == "test" and seed with sample data.
class ReportsControllerTest < ActionController::TestCase
  test "top_urls" do
    get :top_urls, { :format => 'json' }
    assert_response :success
    assert_not_nil assigns(:logs)
  end

  test "top_referrers" do
    get :top_referrers, { :format => 'json' }
    assert_response :success
    assert_not_nil assigns(:logs)
  end
end
