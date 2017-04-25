class CheckIn < ApplicationRecord
  belongs_to :user
  belongs_to :project
  belongs_to :muster, required: false
end
