Rails.application.routes.draw do
  get "/top_urls" => "reports#top_urls"
  get "/top_referrers" => "reports#top_referrers"
end
