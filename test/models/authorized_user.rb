require_relative "../../lib/perm"

class AuthorizedUser < Perm::Authorized
  def can_read?(post)
    return true if user.roles.include?(:admin)
    return true if user.roles.include?(:editor)
    return true if user == post.user
    post.published
  end

  def can_update?(post)
    return true if user.roles.include?(:admin)
    return true if user.roles.include?(:editor)
    user == post.user
  end

  def can_delete?(post)
    return true if user.roles.include?(:admin)
    user == post.user
  end
end
