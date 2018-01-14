[![Lines of Code](http://img.shields.io/badge/lines_of_code-49-brightgreen.svg?style=flat)](http://blog.codinghorror.com/the-best-code-is-no-code-at-all/)
[![Code Status](http://img.shields.io/codeclimate/maintainability/hopsoft/perm.svg?style=flat)](https://codeclimate.com/github/hopsoft/perm)
[![Dependency Status](http://img.shields.io/gemnasium/hopsoft/perm.svg?style=flat)](https://gemnasium.com/hopsoft/perm)
[![Build Status](http://img.shields.io/travis/hopsoft/perm.svg?style=flat)](https://travis-ci.org/hopsoft/perm)
[![Coverage Status](https://img.shields.io/coveralls/hopsoft/perm.svg?style=flat)](https://coveralls.io/r/hopsoft/perm?branch=master)
[![Downloads](http://img.shields.io/gem/dt/perm.svg?style=flat)](http://rubygems.org/gems/perm)

# Perm

Incredibly simple permission management i.e. authorization.

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
  attr_accessor :posts
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
    return true if post.published
    return true if user == post.user
    user.has_one_role?(:admin, :editor)
  end

  def can_update?(post)
    return true if user == post.user
    user.has_one_role?(:admin, :editor)
  end

  def can_delete?(post)
    return true if user == post.user
    user.has_role?(:admin)
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
beth.posts = []

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

## Rails Example

_This example uses a Rails model for role management instead of Roleup._

Continuing with the users & posts example...
your directory structure should look something like this.
_Note that only the structure required for the example is shown._

```
|- app
  |- authorizers
    |- post_authorizer.rb
  |- controllers.rb
    |- posts_controller.rb
  |- models
    |- post.rb
    |- role.rb
    |- user.rb
```

#### Models

```ruby
class User < ActiveRecord::Base
  has_many :posts
  has_and_belongs_to_many :roles

  def role_names
    roles.map(&:name)
  end
end
```

```ruby
class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
  validates :name, presence: true
end
```

```ruby
class Post < ActiveRecord::Base
  belongs_to :user
end
```

#### Authorizer

```ruby
class PostAuthorizer < Perm::Authorizer
  def can_read?(post)
    return true if post.published?
    return true if user == post.user
    (user.role_names & ["Adminstrator", "Editor"]).present?
  end

  def can_update?(post)
    return true if user == post.user
    (user.role_names & ["Adminstrator", "Editor"]).present?
  end

  def can_delete?(post)
    return true if user == post.user
    user.role_names.include?("Adminstrator")
  end
end
```

#### Controller

```ruby
class PostsController < ApplicationController
  include Perm::HasAuthorizer
  authorizes_with PostAuthorizer, :current_user

  # note: current_user would typically be handled by a library like devise
  def current_user
    @current_user ||= User.find(session[:user_id])
  end

  def show
    post = Post.find(params[:id])
    if authorized_user.can_read?(post)
      # render show
    else
      # render unauthorized
    end
  end

  def update
    post = Post.find(params[:id])
    if authorized_user.can_update?(post)
      # render update
    else
      # render unauthorized
    end
  end

  def delete
    post = Post.find(params[:id])
    if authorized_user.can_delete?(post)
      # render delete
    else
      # render unauthorized
    end
  end
end
```
