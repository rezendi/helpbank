class Image < ApplicationRecord
  has_attached_file :file, styles: { medium: "300x300>", thumb: "100x100>" }
  validates_attachment_content_type :file, presence: true, content_type: /\Aimage\/.*\z/

  belongs_to :community, required: false
  belongs_to :project, required: false
  belongs_to :muster, required: false
  belongs_to :user
  
  SUBMITTED = 0
  APPROVED = 1
end
