[![Lines of Code](http://img.shields.io/badge/lines_of_code-29-brightgreen.svg?style=flat)](http://blog.codinghorror.com/the-best-code-is-no-code-at-all/)
[![Maintainability](https://api.codeclimate.com/v1/badges/b4cb74544d60f1e17660/maintainability)](https://codeclimate.com/github/hopsoft/perm/maintainability)
[![Build Status](http://img.shields.io/travis/hopsoft/perm.svg?style=flat)](https://travis-ci.org/hopsoft/perm)
[![Coverage Status](https://img.shields.io/coveralls/hopsoft/perm.svg?style=flat)](https://coveralls.io/r/hopsoft/perm?branch=master)
[![Downloads](http://img.shields.io/gem/dt/perm.svg?style=flat)](http://rubygems.org/gems/perm)

# Perm

Incredibly simple permission management i.e. authorization.

## Quickstart

```sh
gem install perm
```

### Setup

Let's create a simple example with __users__ & __posts__.

```ruby
class User
  attr_reader :roles, :posts

  def initialize(roles: [])
    @roles = roles
    @posts = []
  end
end
```

```ruby
class Post
  attr_reader :user, :title
  attr_accessor :published

  def initialize(user:, title:)
    @user = user
    @title = title
    @user.posts << self
  end
end
```

Once our basic classes have be defined, we can create an authorized user to manage permissions.

```ruby
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
```

Authorized users do the following.

- wrap user objects &mdash; _somewhat like the presenter pattern_
- add behavior to wrapped users
- respond to authorization methods defined as `can_OPERATION?`
- secure by default _i.e. authorization checks return false until implemented_

### Usage

#### Create some users

```ruby
mary = User.new(roles: [:admin])
john = User.new(roles: [:editor, :writer])
beth = User.new(roles: [:writer])
drew = User.new
```

#### Create a post

```ruby
post = Post.new(user: beth, title: "Authorization made easy")
```

#### Wrap each user with an authorizer
```ruby
authorized_mary = AuthorizedUser.new(mary)
authorized_john = AuthorizedUser.new(john)
authorized_beth = AuthorizedUser.new(beth)
authorized_drew = AuthorizedUser.new(drew)

# wrapped users continue to act like users
authorized_beth.posts # => [#<Post:0x007fe35d081798 @title="Authorization made easy"...

# if conflicts arise, simply access the original
authorized_beth.user
```

#### Check permissions

```ruby
authorized_mary.can_read?(post) # => true
authorized_mary.can_update?(post) # => true
authorized_mary.can_delete?(post) # => true

authorized_john.can_read?(post) # => true
authorized_john.can_update?(post) # => true
authorized_john.can_delete?(post) # => false

authorized_beth.can_read?(post) # => true
authorized_beth.can_update?(post) # => true
authorized_beth.can_delete?(post) # => true

authorized_drew.can_read?(post) # => false
authorized_drew.can_update?(post) # => false
authorized_drew.can_delete?(post) # => false

post.published = true
authorized_drew.can_read?(post) # => true

# we can also check unimplemented permissions
authorized_mary.can_create?(post) # => false
authorized_john.can_view?(post) # => false
```
