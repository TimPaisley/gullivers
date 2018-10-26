class VisitsController < ApplicationController
    def create
        current_user.visits.create!(location_id: params[:location_id])
        render json: { message: "success" }
    end
end
