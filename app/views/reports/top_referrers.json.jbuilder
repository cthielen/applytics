@logs.each do |day, sites|
  json.set! day do
    json.array! sites do |site|
      json.url site[:url]
      json.visits site[:visits]
      json.referrers site[:referrers]
    end
  end
end