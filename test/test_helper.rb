require "simplecov"
require 'coveralls'

SimpleCov.start
SimpleCov.command_name "mt"
Coveralls.wear!

require_relative "../lib/perm"
