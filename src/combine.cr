require "../config/application"

def sync
  harvest = Harvest.new(
    Amber.settings.secrets["harvest_account_id"],
    Amber.settings.secrets["harvest_token"],
  )

  Sync.new(harvest).run
end

def cleanup
  harvest = Harvest.new(
    Amber.settings.secrets["harvest_account_id"],
    Amber.settings.secrets["harvest_token"],
  )

  Sync.new(harvest).cleanup(Time.local, Time.local.shift(months: -2))
end

# Run cron tasks in the master process.
if Amber::Cluster.master?
  CronScheduler.define do
    at("5 * * * *") { sync }
    at("0 1 * * *") { cleanup }
  end
end

Amber::Support::ClientReload.new if Amber.settings.auto_reload?
Amber::Server.start
