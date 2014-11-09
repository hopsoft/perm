require_relative "test_helper"

module Perm
  class HasAuthorizerTest < MicroTest::Test

    class ExampleAuthorizer < Authorizer
      def can_view?(object)
        user[:roles].include? :viewer
      end
    end

    class Example
      include HasAuthorizer
      authorizes_with ExampleAuthorizer, :current_user

      attr_writer :current_user
      def current_user
        @current_user ||= { roles: [:viewer] }
      end
    end

    before do
      @example = Example.new
    end

    test "viewer can view" do
      assert @example.authorized_user.can_view?({})
    end

    test "non-viewer cannot view" do
      example = Example.new
      example.current_user = { roles: [:other] }
      assert !example.authorized_user.can_view?({})
    end

  end
end

