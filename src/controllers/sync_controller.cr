class SyncController < ApplicationController
  def sync
    if context.current_user.try &.is_admin && !Combine.syncing?
      spawn do
        Combine.resync
      end

      redirect_to "/", flash: {"success" => "Starting sync."}
    end
  end
end
