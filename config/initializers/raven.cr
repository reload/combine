require "raven"
require "raven/integrations/amber"

Raven.configure do |config|
  # ...
  config.async = true
  config.current_environment = Amber.env.to_s
end
