require "delegate"

module Perm
  class Authorizer < SimpleDelegator
    attr_reader :user

    def initialize(user)
      super @user = user
    end

    def method_missing(name, *args)
      return false if can_method?(name)
      super
    end

    def respond_to?(name)
      return true if can_method?(name)
      super
    end

    protected

    def can_method?(name)
      !!(name.to_s =~ /\Acan_.+\?\z/)
    end
  end
end
