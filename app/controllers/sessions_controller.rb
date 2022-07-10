class SessionsController < ApplicationController
  prepend_before_action :authenticate_user!, only: %i[index show destroy]

  def index
    @sessions = @current_user.sessions
    render jsonapi: @sessions, include: [:user]
  end

  def show
  end

  def create
    username = params["username"]
    password = params["password"]
    ip = request.ip
    user_agent = request.user_agent

    login_data = AuthHelper.login(username, password, ip, user_agent)

    response.headers["Access-Token"] = login_data[:jwt]
    response.headers["Refresh-Token"] = login_data[:refresh_token]
    response.headers["Expire-At"] = login_data[:exp]
  end

  def update
  end

  def destroy
    if params[:id] == "current"
      @current_session.update(logged_out: true)
    else
      @session = Session.find_by(id: params[:id])
      @session.update(logged_out: true)
      render jsonapi: @session, include: [:user]
    end
  end
end