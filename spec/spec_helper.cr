ENV["AMBER_ENV"] ||= "test"

require "spec"
require "micrate"

require "../config/application"

# Disable logging in tests.
Log.builder.clear

Micrate::DB.connection_url = ENV["DATABASE_URL"]? || Amber.settings.database_url
# Automatically run migrations on the test database
Micrate::Cli.run_up
