require 'uri'

class Link < ApplicationRecord
  belongs_to :community, required: false
  belongs_to :project, required: false
  belongs_to :muster, required: false
  belongs_to :user
  
  validate :valid_url?

  def valid_url?
    valid = false
    begin
      uri = URI.parse(url)
      valid = uri.is_a?(URI::HTTP) && !uri.host.nil?
    rescue URI::InvalidURIError
      valid = false
    end
    errors.add(:url, "Invalid URL") if !valid
  end
end
