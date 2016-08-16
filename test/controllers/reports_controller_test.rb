require 'test_helper'

# TODO: Support SQLite for Sequel when Rails.env == "test" and seed with sample data.
class ReportsControllerTest < ActionController::TestCase
  test "top_urls" do
    get :top_urls, { :format => 'json' }
    assert_response :success
    assert_not_nil assigns(:logs)

    body = JSON.parse(response.body)

    body.each do |day, entries|
      entries.each do |entry|
        assert entry.include?('url'), 'JSON response should include url field'
        assert entry.include?('visits'), 'JSON response should include visits field'
      end
    end
  end

  test "top_referrers" do
    get :top_referrers, { :format => 'json' }
    assert_response :success
    assert_not_nil assigns(:logs)

    body = JSON.parse(response.body)

    body.each do |day, entries|
      entries.each do |entry|
        assert entry.include?('url'), 'JSON response should include url field'
        assert entry.include?('visits'), 'JSON response should include visits field'
        assert entry.include?('referrers'), 'JSON response should include referrers field'
        entry['referrers'].each do |referrer|
          assert referrer.include?('url'), 'JSON response should include url field'
          assert referrer.include?('visits'), 'JSON response should include visits field'
        end
      end
    end
  end
end
