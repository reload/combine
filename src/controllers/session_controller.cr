class SessionController < ApplicationController
  def new
    user = User.new
    render("new.ecr")
  end

  def create
    user = User.find_by(email: params["email"].to_s)
    if user && user.authenticate(params["password"].to_s)
      session[:user_id] = user.id
      flash[:info] = "Successfully logged in"
      redirect_to "/"
    else
      flash[:danger] = "Invalid email or password"
      user = User.new
      render("new.ecr")
    end
  end

  def delete
    session.delete(:user_id)
    flash[:info] = "Logged out. See ya later!"
    redirect_to "/"
  end

  def google_signin
    redirect_to multi_auth.authorize_uri
  end

  def google_callback
    query = request.query

    unless query
      halt!(404, "Not found")

      return
    end

    mail = multi_auth.user(HTTP::Params.parse(query)).email

    unless mail
      halt!(404, "Not found")

      return
    end

    mail = mail.downcase.strip
    user = User.find_by(email: mail)

    if user
      session[:user_id] = user.id
      flash[:info] = "Successfully logged in"
      redirect_to "/"
    else
      flash[:danger] = "No user associated with #{mail}"
      user = User.new
      render("new.ecr")
    end
  end

  private def multi_auth
    MultiAuth.make("google", "#{Amber::Server.instance.host_url.gsub(/0.0.0.0/, "localhost")}/signin/callback")
  end
end
