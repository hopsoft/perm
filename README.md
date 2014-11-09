# Perm

Incredibly simple permission management.

## Quickstart

```sh
gem install perm
```

We'll use a contrived example of users & posts to demonstrate permission management.

_Note that the user class includes `Roleup::HasRoles`_

```ruby
class User
  include Roleup::HasRoles
  attr_reader :posts

  def initialize
    @posts = []
  end
end
```

```ruby
class Post
  attr_accessor :user, :title, :published
end
```

We also need an authorizer to manage permissions.

_Authorizors wrap users & add behavior to them._

```ruby
class PostAuthorizer < Perm::Authorizer

  def can_read?(post)
    return true if user.has_one_role?(:admin, :editor)
    return true if user == post.user
    post.published
  end

  def can_update?(post)
    return true if user.has_one_role?(:admin, :editor)
    user == post.user
  end

  def can_delete?(post)
    return true if user.has_role?(:admin)
    user == post.user
  end

end
```

Lets try it out.

```ruby
# create some users with roles
mary = User.new
mary.roles = [:admin]

john = User.new
john.roles = [:editor, :writer]

beth = User.new
beth.roles = [:writer]

drew = User.new

# create a post
post = Post.new("Authorization made easy")
post.user = beth

# wrap each user with a post authorizer & check permissions
mary = PostAuthorizer.new(mary)
mary.can_read?(post) # => true
mary.can_update?(post) # => true
mary.can_delete?(post) # => true

john = PostAuthorizer.new(john)
john.can_read?(post) # => true
john.can_update?(post) # => true
john.can_delete?(post) # => false

beth = PostAuthorizer.new(beth)
beth.can_read?(post) # => true
beth.can_update?(post) # => true
beth.can_delete?(post) # => true

drew = PostAuthorizer.new(drew)
drew.can_read?(post) # => false
drew.can_update?(post) # => false
drew.can_delete?(post) # => false
post.published = true
drew.can_read?(post) # => true
```
