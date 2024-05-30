class UserController < ApplicationController
  def index
    users = User.all
    render "admin/users.ecr"
  end

  def edit
    user = User.find! params[:id]
    render "admin/user.ecr"
  end

  def update
    user = User.find! params[:id]

    # Set to zero per default.
    user.working_hours = 0
    user.billability_goal = 0

    user.set_attributes user_update_params.validate!.reject { |_, p| !p || p.blank? }

    if user.save
      redirect_to "/admin", flash: {"success" => "User has been updated."}
    else
      flash[:danger] = "Could not update User!"
      render "admin/user.ecr"
    end
  end

  def user_update_params
    params.validation do
      optional(:working_hours) { |p| !!p.match(/^([0-9.]+)$/) }
      optional(:billability_goal) { |p| !!p.match(/^([0-9.]+)$/) }
    end
  end
end
