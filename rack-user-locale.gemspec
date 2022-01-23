# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rack/user-locale/version"

Gem::Specification.new do |spec|
  spec.authors = ["Stuart Chinery"]
  spec.description = "A Rack module for getting and setting a user's locale via a cookie or browser default language."
  spec.email = ["code@technicalpanda.co.uk"]
  spec.files = Dir["lib/**/*", "MIT-LICENSE", "Rakefile", "README.md", "VERSION"]
  spec.homepage = "https://github.com/technicalpanda/rack-user-locale"
  spec.license = "MIT"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.name = "rack-user-locale"
  spec.required_ruby_version = ">= 2.7"
  spec.summary = "A Rack module for getting and setting a user's locale"
  spec.version = Rack::UserLocale::VERSION

  spec.add_dependency "i18n", ">= 1.8.2"
  spec.add_dependency "rack", ">= 2.2.0"
end
