class AdventuresController < ApplicationController
    def index
        render json: Adventure.all, include: :locations
    end
end