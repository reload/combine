require "raven"
require "raven/integrations/amber"

# Raven uses the `uname` command to determine the OS the app is
# running on, but in the scratch image we create there's no other
# binaries installed. So patch it to deal with that case.
module Raven
  class Context
    class_getter os_context : AnyHash::JSON do
      if File.executable? "/bin/uname"
        {
          name:           Raven.sys_command("uname -s"),
          version:        Raven.sys_command("uname -v"),
          build:          Raven.sys_command("uname -r"),
          kernel_version: Raven.sys_command("uname -a") || Raven.sys_command("ver"), # windows
        }.to_any_json
      else
        {
          name: "Docker scratch image",
        }.to_any_json
      end
    end
  end
end

Raven.configure do |config|
  # ...
  config.async = true
  config.current_environment = Amber.env.to_s
end
