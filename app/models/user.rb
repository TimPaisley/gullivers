class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # Disabled :registerable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

    has_many :visits
    has_many :locations, through: :visits
end
