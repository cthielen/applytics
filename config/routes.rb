Rails.application.routes.draw do
  get "/top_urls" => "reports#top_urls", defaults: { format: :json }
  get "/top_referrers" => "reports#top_referrers", defaults: { format: :json }

  root 'reports#index'
end
