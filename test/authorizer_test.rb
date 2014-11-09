require "simplecov"
require 'coveralls'

SimpleCov.start
SimpleCov.command_name "mt"
Coveralls.wear!

require_relative "../lib/perm"

module Perm
  class AuthorizerTest < MicroTest::Test
    class User
      include Roleup::HasRoles
      attr_reader :posts

      def initialize
        @posts = []
      end
    end

    class Post
      attr_accessor :user, :title, :published
    end

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

    before do
      @umary = User.new
      @umary.roles = [:admin]
      @mary = PostAuthorizer.new(@umary)

      john = User.new
      john.roles = [:editor, :writer]
      @john = PostAuthorizer.new(john)

      beth = User.new
      beth.roles = [:writer]
      @beth = PostAuthorizer.new(beth)

      @drew = PostAuthorizer.new(User.new)

      @post = Post.new
      @post.title = "Authorization made easy"
      @post.user = beth
      beth.posts << @post
    end

    test "authorizers respond to all can_*? methods" do
      assert @mary.respond_to?(:can_perform_magic?)
      assert !@mary.can_perform_magic?
      assert !@mary.respond_to?(:can_do_anything)
    end

    test "authorizers expose the wrapped user" do
      assert @mary.user == @umary
    end

    test "authorizers forward non-can_*? messages to wrapped object" do
      assert @mary.posts.is_a?(Array)
    end

    test "mary can read" do
      assert @mary.can_read?(@post)
    end

    test "mary can update" do
      assert @mary.can_update?(@post)
    end

    test "mary can delete" do
      assert @mary.can_delete?(@post)
    end

    test "john can read" do
      assert @john.can_read?(@post)
    end

    test "john can update" do
      assert @john.can_update?(@post)
    end

    test "john cannot delete" do
      assert !@john.can_delete?(@post)
    end

    test "beth can read" do
      assert @beth.can_read?(@post)
    end

    test "beth can update" do
      assert @beth.can_update?(@post)
    end

    test "beth can delete" do
      assert @beth.can_delete?(@post)
    end

    test "drew cannot read" do
      assert !@drew.can_read?(@post)
    end

    test "drew cannot update" do
      assert !@drew.can_update?(@post)
    end

    test "drew cannot delete" do
      assert !@drew.can_delete?(@post)
    end

    test "drew can read after published" do
      @post.published = true
      assert @drew.can_read?(@post)
    end

  end
end
