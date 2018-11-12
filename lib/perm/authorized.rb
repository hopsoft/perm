# frozen_string_literal: true
require "delegate"

class Perm::Authorized < SimpleDelegator
  attr_reader :subject

  def initialize(subject)
    raise ArgumentError.new("subject cannot be nil") if subject.nil?
    super @subject = subject
  end

  # @deprecated Please use #subject instead
  def user
    warn "The #user method has been deprecated in favor of #subject"
    subject
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
