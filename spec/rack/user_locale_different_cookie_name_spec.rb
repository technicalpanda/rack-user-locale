# frozen_string_literal: true

require "basic_rack_app"
require "rack/builder"

RSpec.describe Rack::UserLocale do
  def app
    Rack::Builder.new do
      use Rack::UserLocale, cookie_name: "foo-locale"

      I18n.enforce_available_locales = false
      I18n.default_locale = :en
      I18n.locale = :en

      run BasicRackApp.new
    end
  end

  it "has I18n.locale initially set to :en" do
    expect(I18n.locale).to eq(:en)
  end

  context "when a locale cookie is set" do
    before do
      get "http://example.com/", {}, "HTTP_COOKIE" => "foo-locale=es", "SCRIPT_NAME" => "/"
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

  context "when from HTTP_ACCEPT_LANGUAGE headers with a single locale" do
    before do
      get "http://example.com/", {}, "HTTP_ACCEPT_LANGUAGE" => "fr-be", "SCRIPT_NAME" => "/"
    end

    it "sets the locale in the response body" do
      expect(last_response.body).to eq("Locale: fr")
    end

    it "sets a cookie in the response" do
      expect(last_response["Set-Cookie"]).to eq("foo-locale=fr; path=/")
    end

    it "resets I18n.locale back to :en" do
      expect(I18n.locale).to eq(:en)
    end
  end

  context "when from HTTP_ACCEPT_LANGUAGE headers with an multiple locales" do
    before do
      get "http://example.com/",
          {},
          "HTTP_ACCEPT_LANGUAGE" => "de-DE;q=0.8,de;q=0.8,no-NO;q=1.0,no;q=0.7,ru-RU;q=0.7," \
                                    "sv-SE;q=0.4,sv;q=0.3,nl-BE;q=0.9",
          "SCRIPT_NAME" => "/"
    end

    it "sets the locale in the response body" do
      expect(last_response.body).to eq("Locale: no")
    end

    it "sets a cookie in the response" do
      expect(last_response["Set-Cookie"]).to eq("foo-locale=no; path=/")
    end

    it "resets I18n.locale back to :en" do
      expect(I18n.locale).to eq(:en)
    end
  end

  context "when both a cooke and HTTP_ACCEPT_LANGUAGE headers are set" do
    before do
      get "http://example.com/",
          {},
          "HTTP_COOKIE" => "foo-locale=af",
          "HTTP_ACCEPT_LANGUAGE" => "ar-sa",
          "SCRIPT_NAME" => "/"
    end

    it "sets the locale in the response body" do
      expect(last_response.body).to eq("Locale: af")
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
      expect(last_response["Set-Cookie"]).to eq("foo-locale=en; path=/")
    end

    it "resets I18n.locale back to :en" do
      expect(I18n.locale).to eq(:en)
    end
  end
end
