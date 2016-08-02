json.cache! @cache_key do
  @logs.each do |day, sites|
    json.set! day do
      json.array! sites do |site|
          json.(site, :url, :visits)
      end
    end
  end
end
