class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :display_spa

  def display_spa
    if user_signed_in? && request.format.html? && !request.path.start_with?("/users")
        render "guide/index"
    end
  end
end
