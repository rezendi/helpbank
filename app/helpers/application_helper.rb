module ApplicationHelper
  def display_user(user)
    return "You" if current_user.present? && current_user.id == user.id
    s = user.to_s
    return s if current_user.is_admin?
    return s.split("@")[0] if s.include? "@"
    words = s.split(" '")
    return "#{words[0]} #{words[1] ? words[1].first : ''}"
  end
  
  def avatar_for(user)
    if user.personal_images.any?
      image_tag user.personal_images.first.file.url(:thumb)
    end
  end
  
  def current_user_admin_of?(c_or_p)
    return user_signed_in? && current_user.is_admin_of?(c_or_p)
  end

  def current_user_member_of?(c_or_p)
    return user_signed_in? && current_user.is_member_of?(c_or_p)
  end
end
