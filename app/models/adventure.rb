class Adventure < ApplicationRecord
    has_many :adventure_locations
    has_many :locations, through: :adventure_locations

    validates :locations, presence: true
end
