# frozen_string_literal: true

require "rubygems"
require "bundler"
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn "Run `bundle install` to install missing gems"
  exit e.status_code
end
require "rake"

require "jeweler"
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "rack-user-locale"
  gem.homepage = "http://github.com/schinery/rack-user-locale"
  gem.license = "MIT"
  gem.summary = %(Rack module for getting and setting a user's locale)
  gem.description = %(A Rack module for getting and setting a user's locale via a cookie or browser default language.)
  gem.email = "stuart.chinery@gmail.com"
  gem.authors = ["Stuart Chinery", "Dave Hrycyszyn"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require "rake/testtask"
Rake::TestTask.new(:test) do |test|
  test.libs << "lib" << "test"
  test.pattern = "test/**/*_test.rb"
  test.verbose = true
end

task default: :test

require "yard"
YARD::Rake::YardocTask.new
