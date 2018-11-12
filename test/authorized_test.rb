# frozen_string_literal: true
require_relative "test_helper"

module Perm
  class AuthorizedTest < PryTest::Test

    before do
      @mary = User.new(roles: [:admin])
      @authorized_mary = AuthorizedUser.new(@mary)

      john = User.new(roles: [:editor, :writer])
      @authorized_john = AuthorizedUser.new(john)

      beth = User.new(roles: [:writer])
      @post = Post.new(user: beth, title: "Authorization made easy")
      @authorized_beth = AuthorizedUser.new(beth)

      drew = User.new(roles: [])
      @authorized_drew = AuthorizedUser.new(drew)

    end

    test "cannot wrap nil" do
      begin
        AuthorizedUser.new nil
      rescue ArgumentError => error
      end
      assert error
    end

    test "authorizers respond to all can_*? methods" do
      assert @authorized_mary.respond_to?(:can_perform_magic?)
      assert !@authorized_mary.can_perform_magic?
      assert !@authorized_mary.respond_to?(:can_do_anything)
    end

    test "authorizers expose the wrapped subject" do
      assert @authorized_mary.subject == @mary
    end

    test "authorizers forward non-can_*? messages to wrapped object" do
      assert @authorized_mary.posts.is_a?(Array)
    end

    test "mary can read" do
      assert @authorized_mary.can_read?(@post)
    end

    test "mary can update" do
      assert @authorized_mary.can_update?(@post)
    end

    test "mary can delete" do
      assert @authorized_mary.can_delete?(@post)
    end

    test "john can read" do
      assert @authorized_john.can_read?(@post)
    end

    test "john can update" do
      assert @authorized_john.can_update?(@post)
    end

    test "john cannot delete" do
      assert !@authorized_john.can_delete?(@post)
    end

    test "beth can read" do
      assert @authorized_beth.can_read?(@post)
    end

    test "beth can update" do
      assert @authorized_beth.can_update?(@post)
    end

    test "beth can delete" do
      assert @authorized_beth.can_delete?(@post)
    end

    test "drew cannot read" do
      assert !@authorized_drew.can_read?(@post)
    end

    test "drew cannot update" do
      assert !@authorized_drew.can_update?(@post)
    end

    test "drew cannot delete" do
      assert !@authorized_drew.can_delete?(@post)
    end

    test "drew can read after published" do
      @post.published = true
      assert @authorized_drew.can_read?(@post)
    end

  end
end
