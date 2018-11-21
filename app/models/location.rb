class Location < ApplicationRecord

    has_many :visits
    has_many :users, through: :visits

    has_many :adventure_locations
    has_many :adventure, through: :adventure_locations
end
