require "forwardable"

module Perm
  module HasAuthorizer
    extend Forwardable
    def_delegators :"self.class", :authorizer_class, :user_method

    def self.included(mod)
      class << mod
        attr_reader :authorizer_class, :user_method
        def authorizes_with(klass, user_method)
          @authorizer_class = klass
          @user_method = user_method
        end
      end
    end

    def authorized_user
      @authorized_user ||= authorizer_class.new(send(user_method))
    end
  end
end
