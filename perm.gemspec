# coding: utf-8
require File.join(File.dirname(__FILE__), "lib/perm/version")

Gem::Specification.new do |spec|
  spec.name                  = "perm"
  spec.version               = Perm::VERSION
  spec.license               = "MIT"
  spec.homepage              = "https://github.com/hopsoft/perm"
  spec.summary               = "Simple permission management"
  spec.description           = "Simple permission management"
  spec.authors               = ["Nathan Hopkins"]
  spec.email                 = ["natehop@gmail.com"]

  spec.files = Dir["lib/**/*.rb", "[A-Z].*"]
  spec.test_files = Dir["test/**/*.rb"]

  spec.add_dependency "roleup"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "micro_test"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
end

