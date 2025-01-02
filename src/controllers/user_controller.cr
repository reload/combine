class UserController < ApplicationController
  getter user = User.new

  before_action do
    only [:edit, :update] { set_user }
  end

  def index
    users = User.all
    render "index.ecr"
  end

  def edit
    render("edit.ecr")
  end

  def update
    if context.current_user.try &.is_admin
      # Set to zero per default.
      user.working_hours = 0
      user.billability_goal = 0
    end

    params = user_params.validate!.reject { |_, p| !p || p.blank? }

    # Password isn't a regular column, so we have to set it explicitly.
    if password = params["password"]?
      user.password = password
    end

    user.set_attributes params
    if user.save
      redirect_to "/", flash: {"success" => "User has been updated."}
    else
      flash[:danger] = "Could not update User!"
      render "edit.ecr"
    end
  end

  private def user_params
    params.validation do
      if context.current_user.try &.is_admin
        optional(:working_hours) { |p| !!p.match(/^([0-9.]+)$/) }
        optional(:billability_goal) { |p| !!p.match(/^([0-9.]+)$/) }
      end
      optional(:password) { |p| !!p.presence}
    end
  end

  private def set_user
    @user = User.find! params[:id]
  end
end
