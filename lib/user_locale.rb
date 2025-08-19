# frozen_string_literal: true

require "i18n"

module Rack
  class UserLocale
    attr_reader :app, :body, :env, :headers, :options, :status

    def initialize(app, options = {})
      @app = app
      @options = {
        accepted_locales: [],
        cookie_name: "user-locale"
      }.merge(options)
    end

    def call(env)
      @env = env
      locale_to_restore = I18n.locale

      I18n.locale = env["rack.locale"] = new_user_locale

      status, headers, body = app.call(env)

      unless set_cookie?
        Rack::Utils.set_cookie_header!(headers, options[:cookie_name], { value: new_user_locale, path: "/" })
      end

      [status, headers, body]
    ensure
      I18n.locale = locale_to_restore
    end

    private

    def new_user_locale
      @new_user_locale ||= check_accepted? ? accepted_locale_or_default(user_locale) : user_locale
    end

    def request
      @request ||= Rack::Request.new(env)
    end

    def user_locale
      @user_locale ||= (cookie_locale || browser_locale || I18n.default_locale).to_sym
    end

    # Helpers

    def accept_languages
      Array(env["HTTP_ACCEPT_LANGUAGE"]&.split(","))
    end

    def accepted_locale_or_default(locale)
      options[:accepted_locales].include?(locale) ? locale : I18n.default_locale
    end

    def browser_locale
      return if weighted_accepted_languages.empty?
      return weighted_accepted_languages.first unless check_accepted?

      weighted_accepted_languages.detect do |lang|
        options[:accepted_locales].include?(lang.to_sym)
      end
    end

    def check_accepted?
      options[:accepted_locales].any?
    end

    def cookie_locale
      request.cookies[options[:cookie_name]]
    end

    def set_cookie?
      cookie_locale&.to_sym == I18n.locale
    end

    def weighted_accepted_languages
      @weighted_accepted_languages ||= begin
        langs = accept_languages.map do |lang|
          lang += ";q=1.0" unless /;q=\d+\.\d+$/.match?(lang)
          lang.split(";q=")
        end

        langs.sort { |a, b| b[1] <=> a[1] }.map { |lang| lang[0].split("-").first }
      end
    end
  end
end
