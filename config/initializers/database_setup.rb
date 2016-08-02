# Ensure /config/database.yml exists and that our schema is (probably) correct.

# Credentials expected to be in /config/database.yml. We could also check for
# environment variables if that's the desired convention.
DB_CONFIG_FILE = "#{Rails.root.to_s}/config/database.yml"

if File.file?(DB_CONFIG_FILE)
  $DB_CONFIG = YAML.load_file(DB_CONFIG_FILE)
else
  puts "You need to set up #{DB_CONFIG_FILE} before running this application."
  puts "See config/database.example.yml for an example."
  exit(-1)
end

$DB_URL = $DB_CONFIG[Rails.env]["url"]

# Check that the needed table exists. We'll consider this a proxy for the
# proper schema to exist. TODO: Research how Sequel gem users ensure migrations
# have been run.

# Test connect to the database
$db = Sequel.connect($DB_URL)

# Ensure the schema exists.
begin
  $db.schema(:logs)
rescue Sequel::DatabaseConnectionError => e
  STDERR.puts e
  STDERR.puts "Unable to connect to database #{$DB_URL}"
  STDERR.puts "Verify your connection settings in config/database.yml."
  exit(-1)
rescue Sequel::DatabaseError, Sequel::Error => e
  # Connected but could not find schema.
  # We can't error out here as they may be running rake db:migrate
end
