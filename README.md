# Perm

Incredibly simple permission management i.e. authorization.

[![Lines of Code](http://img.shields.io/badge/loc-29-brightgreen.svg)](http://blog.codinghorror.com/the-best-code-is-no-code-at-all/)
[![Dependency Status](https://gemnasium.com/hopsoft/perm.svg)](https://gemnasium.com/hopsoft/perm)
[![Code Climate](https://codeclimate.com/github/hopsoft/perm/badges/gpa.svg)](https://codeclimate.com/github/hopsoft/perm)
[![Travis CI](https://travis-ci.org/hopsoft/perm.svg)](https://travis-ci.org/hopsoft/perm)
[![Coverage Status](https://img.shields.io/coveralls/hopsoft/perm.svg)](https://coveralls.io/r/hopsoft/perm?branch=master)

## Quickstart

```sh
gem install perm
```

#### Setup

We'll use a contrived example of users & posts to demonstrate permission management.

_This example uses [Roleup](https://github.com/hopsoft/roleup) for simple role management & verification, but Roleup is not required._

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

Authorizers do the following.

- wrap user objects
- add behavior to wrapped users
- respond to permissioning methods in the form of `can_OPERATION?`
- are secure by default

_Which permissioning methods you choose to suppport is up to you._

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

#### Create some users with roles

```ruby
mary = User.new
mary.roles = [:admin]

john = User.new
john.roles = [:editor, :writer]

beth = User.new
beth.roles = [:writer]

drew = User.new
```

#### Create a post

```ruby
post = Post.new
post.title = "Authorization made easy"
post.user = beth
beth.posts << post
```

#### Wrap each user with an authorizer
```ruby
mary = PostAuthorizer.new(mary)
john = PostAuthorizer.new(john)
beth = PostAuthorizer.new(beth)
drew = PostAuthorizer.new(drew)

# wrapped users continue to act like users
beth.posts # => [#<Post:0x007fe35d081798 @title="Authorization made easy"...

# if conflicts arise, simply access the original
beth.user
```

#### Check permissions

```ruby
mary.can_read?(post) # => true
mary.can_update?(post) # => true
mary.can_delete?(post) # => true

john.can_read?(post) # => true
john.can_update?(post) # => true
john.can_delete?(post) # => false

beth.can_read?(post) # => true
beth.can_update?(post) # => true
beth.can_delete?(post) # => true

drew.can_read?(post) # => false
drew.can_update?(post) # => false
drew.can_delete?(post) # => false
post.published = true
drew.can_read?(post) # => true

# we can also check unimplemented permissions
mary.can_create?(post) # => false
john.can_view?(post) # => false
```
