class User
  attr_reader :roles, :posts

  def initialize(roles: [])
    @roles = roles
    @posts = []
  end
end
