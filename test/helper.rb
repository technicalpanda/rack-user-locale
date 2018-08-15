# frozen_string_literal: true

require "rubygems"
require "bundler"
require "rack/test"

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn "Run `bundle install` to install missing gems"
  exit e.status_code
end

require "minitest/autorun"
require "minitest/fail_fast"
require "minitest/reporters"
require "minitest/spec"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require "rack-user-locale"

class Minitest::Test
  extend Minitest::Spec::DSL
  include Rack::Test::Methods
end

Minitest::Reporters.use!(
  Minitest::Reporters::SpecReporter.new,
  ENV,
  Minitest.backtrace_filter
)
