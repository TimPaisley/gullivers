class AdventuresController < ApplicationController
    def index
        render json: Adventure.all
    end

    def show
        render json: Adventure.find(params[:id])
    end
end