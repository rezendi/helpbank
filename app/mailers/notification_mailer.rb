class NotificationMailer < ApplicationMailer
  
  def self.send_emails_for(post)
    if post.parent != nil
      NotificationMailer.notification_email(post.parent.user, post, "New response to your HelpBank post").deliver_now if post.parent.user != post.user
      for reply in post.parent.replies
        notification_email(reply.user, post, "New response to a HelpBank post you responded to").deliver_now if reply.user != post.user
      end
    else
      if post.user.is_admin_of? post.project
        for user in project.users
          notification_email(user, post, "New post in HelpBank project #{post.project.name}").deliver_now if user != post.parent.user
        end
      end
    end
  end

  def notification_email(user, post, subject)
    @user = user
    @post = post
    mail(to:user.email, subject: subject)
  end
end