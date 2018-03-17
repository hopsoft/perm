class Post
  attr_reader :user, :title
  attr_accessor :published

  def initialize(user:, title:)
    @user = user
    @title = title
    @user.posts << self
  end
end
