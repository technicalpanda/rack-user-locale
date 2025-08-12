# frozen_string_literal: true

require "basic_rack_app"
require "rack/builder"

RSpec.describe Rack::UserLocale do
  before do
    I18n.enforce_available_locales = false
  end

  describe "without accepted_locales and setting a different cookie_name" do
    let(:cookie_name) { "foo-locale" }

    before do
      def app
        Rack::Builder.new do
          use Rack::UserLocale, cookie_name: "foo-locale"

          run BasicRackApp.new
        end
      end

      I18n.default_locale = :en
      I18n.locale = :en
    end

    it "has I18n.locale initially set to :en" do
      expect(I18n.locale).to eq(:en)
    end

    context "when a locale cookie is set" do
      before do
        header "cookie", "#{cookie_name}=be"
        get "http://example.com/"
      end

      it "has I18n.locale set to :be" do
        expect(I18n.locale).to eq(:be)
      end

      it "does not set a cookie in the response" do
        expect(last_response["Set-Cookie"]).to be_nil
      end
    end

    context "when from HTTP_ACCEPT_LANGUAGE headers with a single locale" do
      before do
        get "http://example.com/", {}, "HTTP_ACCEPT_LANGUAGE" => "fr-be", "SCRIPT_NAME" => "/"
      end

      it "has I18n.locale set to :fr" do
        expect(I18n.locale).to eq(:fr)
      end

      it "sets a cookie in the response" do
        expect(last_response["Set-Cookie"]).to eq("#{cookie_name}=fr; path=/")
      end
    end

    context "when from HTTP_ACCEPT_LANGUAGE headers with an multiple locales" do
      before do
        langs = "de-DE;q=0.8,de;q=0.8,no-NO;q=1.0,no;q=0.7,ru-RU;q=0.7,sv-SE;q=0.4,sv;q=0.3,nl-BE;q=0.9"

        get "http://example.com/",
            {},
            "HTTP_ACCEPT_LANGUAGE" => langs,
            "SCRIPT_NAME" => "/"
      end

      it "has I18n.locale set to :no" do
        expect(I18n.locale).to eq(:no)
      end

      it "sets a cookie in the response" do
        expect(last_response["Set-Cookie"]).to eq("#{cookie_name}=no; path=/")
      end
    end

    context "when both a cooke and HTTP_ACCEPT_LANGUAGE headers are set" do
      before do
        get "http://example.com/",
            {},
            "HTTP_COOKIE" => "#{cookie_name}=af",
            "HTTP_ACCEPT_LANGUAGE" => "ar-sa",
            "SCRIPT_NAME" => "/"
      end

      it "has I18n.locale set to :af" do
        expect(I18n.locale).to eq(:af)
      end

      it "does not set a cookie in the response" do
        expect(last_response["Set-Cookie"]).to be_nil
      end
    end

    context "when nothing is changed" do
      before do
        get "http://example.com/", {}, "SCRIPT_NAME" => "/"
      end

      it "has I18n.locale set to :en" do
        expect(I18n.locale).to eq(:en)
      end

      it "sets a cookie in the response" do
        expect(last_response["Set-Cookie"]).to eq("#{cookie_name}=en; path=/")
      end
    end
  end

  describe "with accepted_locales set and using the default cookie name" do
    let(:cookie_name) { "user-locale" }

    before do
      def app
        Rack::Builder.new do
          use Rack::UserLocale, accepted_locales: %i[en es fr de ja nl]

          run BasicRackApp.new
        end
      end

      I18n.default_locale = :en
      I18n.locale = :en
    end

    it "has I18n.locale initially set to :en" do
      expect(I18n.locale).to eq(:en)
    end

    context "when a locale cookie is already present" do
      before do
        get "http://example.com/", {}, "HTTP_COOKIE" => "#{cookie_name}=es", "SCRIPT_NAME" => "/"
      end

      it "has I18n.locale set to :es" do
        expect(I18n.locale).to eq(:es)
      end

      it "does not set a cookie in the response" do
        expect(last_response["Set-Cookie"]).to be_nil
      end
    end

    context "when HTTP_ACCEPT_LANGUAGE headers has an accepted locale" do
      before do
        get "http://example.com/", {}, "HTTP_ACCEPT_LANGUAGE" => "fr-be", "SCRIPT_NAME" => "/"
      end

      it "has I18n.locale set to :fr" do
        expect(I18n.locale).to eq(:fr)
      end

      it "sets a cookie in the response" do
        expect(last_response["Set-Cookie"]).to eq("#{cookie_name}=fr; path=/")
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

      it "has I18n.locale set to :nl" do
        expect(I18n.locale).to eq(:nl)
      end

      it "sets a cookie in the response" do
        expect(last_response["Set-Cookie"]).to eq("#{cookie_name}=nl; path=/")
      end
    end

    context "when HTTP_ACCEPT_LANGUAGE headers with an multiple locales at the same weight" do
      before do
        get "http://example.com/",
            {},
            "HTTP_ACCEPT_LANGUAGE" => "fr,en,ja",
            "SCRIPT_NAME" => "/"
      end

      it "has I18n.locale set to :fr as it is the first one" do
        expect(I18n.locale).to eq(:fr)
      end

      it "sets a cookie in the response" do
        expect(last_response["Set-Cookie"]).to eq("#{cookie_name}=fr; path=/")
      end
    end

    context "when HTTP_ACCEPT_LANGUAGE headers without an accepted locale" do
      before do
        get "http://example.com/", {}, "HTTP_ACCEPT_LANGUAGE" => "ar-sa", "SCRIPT_NAME" => "/"
      end

      it "has I18n.locale set to the default :en" do
        expect(I18n.locale).to eq(:en)
      end

      it "sets a cookie in the response" do
        expect(last_response["Set-Cookie"]).to eq("#{cookie_name}=en; path=/")
      end
    end

    context "when both a cookie exists and HTTP_ACCEPT_LANGUAGE headers are set" do
      before do
        get "http://example.com/",
            {},
            "HTTP_COOKIE" => "#{cookie_name}=ja",
            "HTTP_ACCEPT_LANGUAGE" => "fr-be",
            "SCRIPT_NAME" => "/"
      end

      it "has I18n.locale set to :ja as it is set in the the cookie" do
        expect(I18n.locale).to eq(:ja)
      end

      it "does not set a cookie in the response" do
        expect(last_response["Set-Cookie"]).to be_nil
      end
    end

    context "when nothing is changed" do
      before do
        get "http://example.com/", {}, "SCRIPT_NAME" => "/"
      end

      it "has I18n.locale set to :en" do
        expect(I18n.locale).to eq(:en)
      end

      it "sets a cookie in the response" do
        expect(last_response["Set-Cookie"]).to eq("#{cookie_name}=en; path=/")
      end
    end

    context "when a POST request is made" do
      before do
        post "http://example.com/",
             {},
             "HTTP_ACCEPT_LANGUAGE" => "fr-be",
             "SCRIPT_NAME" => "/"
      end

      it "has I18n.locale set to :fr" do
        expect(I18n.locale).to eq(:fr)
      end

      it "sets a cookie in the response" do
        expect(last_response["Set-Cookie"]).to eq("#{cookie_name}=fr; path=/")
      end
    end
  end
end
