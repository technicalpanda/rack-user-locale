# frozen_string_literal: true

require "basic_rack_app"
require "rack/builder"

RSpec.describe Rack::UserLocale do
  def app
    Rack::Builder.new do
      use Rack::UserLocale, accepted_locales: %i[en es fr de ja nl]

      I18n.enforce_available_locales = false
      I18n.default_locale = :en
      I18n.locale = :en

      run BasicRackApp.new
    end
  end

  it "has I18n.locale initially set to :en" do
    expect(I18n.locale).to eq(:en)
  end

  context "when a locale cookie is already present" do
    before do
      get "http://example.com/", {}, "HTTP_COOKIE" => "user-locale=es", "SCRIPT_NAME" => "/"
    end

    it "sets the locale in the response body" do
      expect(last_response.body).to eq("Locale: es")
    end

    it "does not set a cookie in the response" do
      expect(last_response["Set-Cookie"]).to be_nil
    end

    it "resets I18n.locale back to :en" do
      expect(I18n.locale).to eq(:en)
    end
  end

  context "when HTTP_ACCEPT_LANGUAGE headers has an accepted locale" do
    before do
      get "http://example.com/", {}, "HTTP_ACCEPT_LANGUAGE" => "fr-be", "SCRIPT_NAME" => "/"
    end

    it "sets the locale in the response body" do
      expect(last_response.body).to eq("Locale: fr")
    end

    it "sets a cookie in the response" do
      expect(last_response["Set-Cookie"]).to eq("user-locale=fr; path=/")
    end

    it "resets I18n.locale back to :en" do
      expect(I18n.locale).to eq(:en)
    end
  end

  context "when HTTP_ACCEPT_LANGUAGE headers with an multiple locales at different weights" do
    before do
      langs = "de-DE;q=0.8,de;q=0.8,no-NO;q=0.7,no;q=0.7,ru-RU;q=0.7,sv-SE;q=0.4,sv;q=0.3,nl-BE;q=0.9"

      get "http://example.com/",
          {},
          "HTTP_ACCEPT_LANGUAGE" => langs,
          "SCRIPT_NAME" => "/"
    end

    it "sets the locale in the response body" do
      expect(last_response.body).to eq("Locale: nl")
    end

    it "sets a cookie in the response" do
      expect(last_response["Set-Cookie"]).to eq("user-locale=nl; path=/")
    end

    it "resets I18n.locale back to :en" do
      expect(I18n.locale).to eq(:en)
    end
  end

  context "when HTTP_ACCEPT_LANGUAGE headers with an multiple locales at the same weight" do
    before do
      get "http://example.com/",
          {},
          "HTTP_ACCEPT_LANGUAGE" => "fr,en,ja",
          "SCRIPT_NAME" => "/"
    end

    it "sets the locale in the response body" do
      expect(last_response.body).to eq("Locale: fr")
    end

    it "sets a cookie in the response" do
      expect(last_response["Set-Cookie"]).to eq("user-locale=fr; path=/")
    end

    it "resets I18n.locale back to :en" do
      expect(I18n.locale).to eq(:en)
    end
  end

  context "when HTTP_ACCEPT_LANGUAGE headers without an accepted locale" do
    before do
      get "http://example.com/", {}, "HTTP_ACCEPT_LANGUAGE" => "ar-sa", "SCRIPT_NAME" => "/"
    end

    it "sets the locale in the response body" do
      expect(last_response.body).to eq("Locale: en")
    end

    it "sets a cookie in the response" do
      expect(last_response["Set-Cookie"]).to eq("user-locale=en; path=/")
    end

    it "resets I18n.locale back to :en" do
      expect(I18n.locale).to eq(:en)
    end
  end

  context "when both a cookie exists and HTTP_ACCEPT_LANGUAGE headers are set" do
    before do
      get "http://example.com/",
          {},
          "HTTP_COOKIE" => "user-locale=ja",
          "HTTP_ACCEPT_LANGUAGE" => "fr-be",
          "SCRIPT_NAME" => "/"
    end

    it "sets the locale in the response body" do
      expect(last_response.body).to eq("Locale: ja")
    end

    it "does not set a cookie in the response" do
      expect(last_response["Set-Cookie"]).to be_nil
    end

    it "resets I18n.locale back to :en" do
      expect(I18n.locale).to eq(:en)
    end
  end

  context "when nothing is changed" do
    before do
      get "http://example.com/", {}, "SCRIPT_NAME" => "/"
    end

    it "sets the locale in the response body" do
      expect(last_response.body).to eq("Locale: en")
    end

    it "sets a cookie in the response" do
      expect(last_response["Set-Cookie"]).to eq("user-locale=en; path=/")
    end

    it "resets I18n.locale back to :en" do
      expect(I18n.locale).to eq(:en)
    end
  end

  context "when a POST request is made" do
    before do
      post "http://example.com/",
           {},
           "HTTP_ACCEPT_LANGUAGE" => "fr-be",
           "SCRIPT_NAME" => "/"
    end

    it "sets the locale in the response body" do
      expect(last_response.body).to eq("Locale: fr")
    end

    it "sets a cookie in the response" do
      expect(last_response["Set-Cookie"]).to eq("user-locale=fr; path=/")
    end

    it "resets I18n.locale back to :en" do
      expect(I18n.locale).to eq(:en)
    end
  end
end
