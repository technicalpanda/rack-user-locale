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
      set_i18n
      app.call(env) && return unless request.get?

      @status, @headers, @body = app.call(env)
      set_response_cookie
      response.finish
    end

    private

    def accepted_locale(locale, other_locale = nil)
      options[:accepted_locales].include?(locale) ? locale : other_locale
    end

    def browser_locale
      @browser_locale ||= detect_browser_locale
    end

    def check_accepted?
      @check_accepted ||= options[:accepted_locales].count.positive?
    end

    def cookie_locale
      @cookie_locale ||= request.cookies[options[:cookie_name]]
    end

    def default_locale
      @default_locale ||= I18n.default_locale
    end

    def detect_browser_locale
      return if http_accept_languages.nil?

      if check_accepted?
        weighted_langs.each do |lang|
          l = accepted_locale(split_lang(lang.first).to_sym)
          return l unless l.nil?
        end
      end

      split_lang(weighted_langs.first.first)
    end

    def http_accept_languages
      @http_accept_languages ||= env["HTTP_ACCEPT_LANGUAGE"]
    end

    def request
      @request ||= Rack::Request.new(env)
    end

    def response
      @response ||= Rack::Response.new(body, status, headers)
    end

    def set_i18n
      new_locale = check_accepted? ? accepted_locale(user_locale.to_sym, default_locale) : user_locale.to_sym
      I18n.locale = env["rack.locale"] = new_locale
    end

    def set_response_cookie
      return if cookie_locale == I18n.locale.to_s

      response.set_cookie(options[:cookie_name], value: I18n.locale, path: "/")
    end

    def split_http_accept_languages
      @split_http_accept_languages ||= http_accept_languages.split(",").map do |l|
        l += ";q=1.0" unless l =~ /;q=\d+\.\d+$/
        l.split(";q=")
      end
    end

    def split_lang(lang)
      return if lang.nil?

      lang.split("-").first
    end

    def user_locale
      @user_locale ||= cookie_locale || browser_locale || default_locale
    end

    def weighted_langs
      @weighted_langs ||= split_http_accept_languages.sort { |a, b| b[1] <=> a[1] }
    end
  end
end
