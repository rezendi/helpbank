class Post < ApplicationRecord
  belongs_to :user
  belongs_to :community, required:false
  belongs_to :project, required:false
  
  def parent
    reply_to_post_id == nil ? nil : Post.find_by_id(reply_to_post_id)
  end

  def replies
    Post.where(reply_to_post_id:self.id)
  end
end
