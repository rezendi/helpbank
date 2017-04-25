class Link < ApplicationRecord
  belongs_to :community, required: false
  belongs_to :project, required: false
  belongs_to :muster, required: false
  belongs_to :user
end
