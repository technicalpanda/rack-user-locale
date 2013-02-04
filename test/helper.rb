require 'rubygems'
require 'bundler'
require "rack/test"
require "debugger"

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'minitest/autorun'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rack-user-locale'
begin; require 'turn/autorun'; rescue LoadError; end

class MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    app = Rack::Builder.new {
      use Rack::UserLocale

      run BasicRackApp.new
    }
  end
end

class BasicRackApp
  def call(env)
    [200, {'Content-Type' => 'text/plain'}, 'Hello World']
  end
end

MiniTest::Unit.autorun