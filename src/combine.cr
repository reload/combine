require "../config/application"

CronScheduler.define do
  at("* * * * *") {
    harvest = Harvest.new(
      Amber.settings.secrets["harvest_account_id"],
      Amber.settings.secrets["harvest_token"],
    )

    Sync.new(harvest).run
  }
end

Amber::Support::ClientReload.new if Amber.settings.auto_reload?
Amber::Server.start
