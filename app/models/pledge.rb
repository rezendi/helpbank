class Pledge < ApplicationRecord
  belongs_to :user
  belongs_to :project
  has_many :sessions
end
