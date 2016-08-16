# Model for table 'logs'.
# Renamed to LogEntry as 'logs' name (required by spec) is a bit generic.
class LogEntry < Sequel::Model(:logs)
  # Provides 'validate' callback
  plugin :validation_helpers

  # Fills in 'created_at' field
  plugin :timestamps

  def validate
    super
    validates_presence [:url]
  end
end
