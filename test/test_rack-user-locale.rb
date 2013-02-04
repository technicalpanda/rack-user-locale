require 'helper'

describe "RackUserLocale" do
  before do
    I18n.default_locale = :en
  end

  it "should have I18n.locale set to :en initially" do
    assert_equal :en, I18n.locale
  end

  describe "when a locale cookie is set" do
    before do
      get 'http://example.com/', {}, 'HTTP_COOKIE' => 'user-locale=es'
    end

    it "should have I18n.locale set to :es" do
      assert_equal :es, I18n.locale
    end

    it "should not set a cookie in the response" do
      assert_equal nil, last_response["Set-Cookie"]
    end
  end

  describe "when from HTTP_ACCEPT_LANGUAGE headers" do
    before do
      get 'http://example.com/', {}, 'HTTP_ACCEPT_LANGUAGE' => 'ru'
    end

    it "should have I18n.locale set to :ru" do
      assert_equal :ru, I18n.locale
    end

    it "should set a cookie in the response" do
      assert_equal "user-locale=ru; domain=example.com; path=/", last_response["Set-Cookie"]
    end
  end

  describe "when both a cooke and HTTP_ACCEPT_LANGUAGE headers are set" do
    before do
      get 'http://example.com/', {}, 'HTTP_COOKIE' => 'user-locale=jp', 'HTTP_ACCEPT_LANGUAGE' => 'fr'
    end

    it "should have I18n.locale set to :jp" do
      assert_equal :jp, I18n.locale
    end

    it "should not set a cookie in the response" do
      assert_equal nil, last_response["Set-Cookie"]
    end
  end

  describe "when nothing is changed" do
    before do
      get 'http://example.com/'
    end

    it "should have I18n.locale set to :en" do
      assert_equal :en, I18n.locale
    end

    it "should set a cookie in the response" do
      assert_equal "user-locale=en; domain=example.com; path=/", last_response["Set-Cookie"]
    end
  end
end
