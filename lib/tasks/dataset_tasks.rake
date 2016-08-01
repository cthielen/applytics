require 'rake'

namespace :dataset do
  # Generates 1m rows for a sample dataset using Sequel.
  # Generated data meets requirements specified in the given 'eng.exercise.md'.
  desc 'Generate a sample dataset of 1m rows.'
  task :generate do
    Rake::Task['environment'].invoke

    # Connect to the database
    DB = Sequel.connect($DB_URL)

    STDERR.puts "This task is not complete. It has created the necessary schema but did not generate data."

    # Generate 5,000 unique URLs which we will re-use to create our 1m rows.
    # We could generate 1m unique URLs but the 'faker' gem is slow and our
    # requirements ask for 1m rows of data, not 1m rows of unique data.
    unique_urls = []
    5000.times.each do
      unique_urls << Faker::Internet.url
    end

    # Ensure our required URLs exist. See eng.exercise.md.
    unique_urls << "http://apple.com" << "https://apple.com" << "https://www.apple.com" << "http://developer.apple.com" << "http://en.wikipedia.org" << "http://opensource.org"

    hits = DB[:logs]
    1000000.times.each do
      url = unique_urls.sample
      referrer = unique_urls.sample
      created_at = Time.at((Time.now.to_f - (Time.now - 11.days).to_f) * rand + (Time.now - 11.days).to_f)
      hits.insert(:url => url,
                  :referrer => referrer,
                  :created_at => created_at,
                  :hash => Digest::MD5.hexdigest({id: 1,
                                                  url: url,
                                                  referrer: referrer,
                                                  created_at: created_at
                                                }.to_s))
    end


  end
end
