require "../config/application"

module Combine
  Micrate::DB.connection_url = Amber.settings.database_url
  Micrate::DB.connect do |db|
    old_version = Micrate.dbversion(db)
    Micrate.up(db)
    new_version = Micrate.dbversion(db)

    # Update all entries with rounded_hours.
    if (old_version < 20240702094302267 && new_version >= 20240702094302267) ||
       # And with billable.
       (old_version < 20250904161223531 && new_version >= 20250904161223531)
      spawn do
        Combine.resync
      end
    end
  end

  # Run cron tasks in the master process.
  if Amber::Cluster.master?
    CronScheduler.define do
      at("*/5 * * * *") { Combine.sync }
      at("0 1 * * *") { Combine.cleanup }
    end
  end

  Amber::Support::ClientReload.new if Amber.settings.auto_reload?
  Amber::Server.start
end
