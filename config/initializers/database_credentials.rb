DB_CONFIG_FILE = "#{Rails.root.to_s}/config/database.yml"

if File.file?(DB_CONFIG_FILE)
  $DB_CONFIG = YAML.load_file(DB_CONFIG_FILE)
else
  puts "You need to set up #{DB_CONFIG_FILE} before running this application."
  puts "See config/database.example.yml for an example."
  exit
end
