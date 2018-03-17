require "delegate"

class Perm::Authorized < SimpleDelegator
  attr_reader :user

  def initialize(user)
    raise ArgumentError.new("user cannot be nil") if user.nil?
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
