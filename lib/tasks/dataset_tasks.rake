require 'rake'

namespace :dataset do
  # Generates 1m rows for a sample dataset using Sequel.
  # Generated data meets requirements specified in the given 'eng.exercise.md'.
  # Task takes about ~110s on a late 2013 MacBook Pro (2.3GHz i7)
  desc 'Generate a sample dataset of 1m rows.'
  task :generate, [:num_rows] => :environment do |t, args|
    NUM_UNIQUE_URLS = 5000 # number of unique URLs to generate
    BATCH_SIZE = 25000     # size of INSERT SQL batch. Tune for performance.
    require 'faker'

    # Check for the proper command line arguments
    if args[:num_rows].nil?
      STDERR.puts "Please specify the number of rows to be generated, e.g.:"
      STDERR.puts "\tbin/rake dataset:generate[1000000]"
      exit(-1)
    elsif Integer(args[:num_rows]) % BATCH_SIZE != 0
      # Ensure we have an evenly divisible batch size. This makes our generating loop
      # a little easier to work with.
      STDERR.puts "Please ensure the number of rows is divisible by #{BATCH_SIZE}."
      STDERR.puts "This constant can be adjusted in lib/tasks/dataset_tasks.rake."
      exit(-1)
    end

    # Generate NUM_UNIQUE_URLS unique URLs which we will re-use to create our 1m rows.
    # We could generate 1m unique URLs but the 'faker' gem is a bit slow and our
    # requirements ask for 1m rows of data, not 1m rows of unique data.
    unique_urls = []
    NUM_UNIQUE_URLS.times.each do
      unique_urls << Faker::Internet.url
    end

    # Ensure our required URLs exist. See eng.exercise.md.
    unique_urls << "http://apple.com" << "https://apple.com" << "https://www.apple.com" << "http://developer.apple.com" << "http://en.wikipedia.org" << "http://opensource.org"

    puts "Generating #{args[:num_rows]} rows based on #{unique_urls.length} URLs ..."

    start_time = Time.now

    # Cache certain values needed for the random created_at values.
    # Caching is necessary as '11.days' performs poorly.
    # created_at formula: (Time.now - (Time.now - 11.days)) * rand + (Time.now - 11.days)
    time_11_days_ago = (Time.now - 11.days).to_f
    rand_time_duration = (Time.now.to_f - time_11_days_ago)

    # TODO: Use multiple threads to generate and insert data faster.

    id = 1
    (Integer(args[:num_rows]) / BATCH_SIZE).times.each do
      rows = []
      BATCH_SIZE.times.each do
        url = unique_urls.sample
        referrer = unique_urls.sample
        created_at = Time.at(rand_time_duration * rand + time_11_days_ago)
        hash = Digest::MD5.hexdigest({id: id, url: url, referrer: referrer, created_at: created_at}.to_s)

        # We will use MySQL to generate the MD5 column for speed. Set to '' for now to satisfy constraints.
        rows << [id, url, referrer, created_at, hash]

        # TODO: Use a MySQL primary key for 'id'. Auto-increment. This should be done as a MySQL auto-incrementing primary key
        # but batch inserting the records + the Ruby-based Digest::MD5 was taking a little longer
        # to solve than I would have liked.
        id = id + 1
      end

      # Use import for faster INSERTs
      $db[:logs].import(
        [:id, :url, :referrer, :created_at, :hash],
        rows
      )
    end

    puts "Finished generating rows. Task took #{Time.now - start_time}s."
  end
end
