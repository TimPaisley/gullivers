class Location < ApplicationRecord

    has_many :visits
    has_many :users, through: :visits

    has_one :adventure_locations
    has_one :adventure, through: :adventure_locations
end
