# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rack/user-locale/version"

Gem::Specification.new do |spec|
  spec.authors = ["Stuart Chinery"]
  spec.description = "A Rack module for getting and setting a user's locale via a cookie or browser default language."
  spec.email = ["stuart.chinery@gmail.com"]
  spec.files = Dir["lib/**/*", "MIT-LICENSE", "Rakefile", "README.md", "VERSION"]
  spec.homepage = "https://github.com/schinery/rack-user-locale"
  spec.license = "MIT"
  spec.name = "rack-user-locale"
  spec.summary = "A Rack module for getting and setting a user's locale"
  spec.version = Rack::UserLocale::VERSION

  spec.add_dependency "i18n", ">= 1.7.0"
  spec.add_dependency "rack", ">= 2.0.8"
  spec.add_development_dependency "rack-test", "~> 1.1"
  spec.add_development_dependency "rake", "~> 13.0"
end
