module Combine
  @@sync = Sync.new(Harvest.new(
                     Amber.settings.secrets["harvest_account_id"],
                     Amber.settings.secrets["harvest_token"],
                   ))
end
