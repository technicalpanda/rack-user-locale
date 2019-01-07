# frozen_string_literal: true

require "i18n"

module Rack
  class UserLocale
    # TODO: Write notes
    #
    def initialize(app, options = {})
      @app = app
      @options = {
        accepted_locales: []
      }.merge(options)
    end

    # TODO: Write notes
    #
    def call(env)
      @env = env
      @request = Rack::Request.new(@env)
      set_locale

      @app.call(env) && return if @request.post? || @request.put? || @request.delete?

      status, headers, body = @app.call(@env)
      response = Rack::Response.new(body, status, headers)
      response.set_cookie("user-locale", value: I18n.locale, path: "/") if cookie_locale != I18n.locale.to_s
      response.finish
    end

    private

    # TODO: Write notes
    #
    def set_locale
      new_locale = check_accepted? ? accepted_locale(locale.to_sym, default_locale) : locale.to_sym
      I18n.locale = @env["rack.locale"] = new_locale
    end

    # TODO: Write notes
    #
    def accepted_locale(locale, other_locale = nil)
      @options[:accepted_locales].include?(locale) ? locale : other_locale
    end

    # TODO: Write notes
    #
    def locale
      cookie_locale || browser_locale || default_locale
    end

    # TODO: Write notes
    #
    def cookie_locale
      @request.cookies["user-locale"]
    end

    # TODO: Write notes
    #
    def browser_locale
      accept_lang = @env["HTTP_ACCEPT_LANGUAGE"]
      return if accept_lang.nil?

      langs = accept_lang.split(",").map do |l|
        l += ";q=1.0" unless l =~ /;q=\d+\.\d+$/
        l.split(";q=")
      end

      langs.sort! { |a, b| b[1] <=> a[1] }

      if check_accepted?
        langs.each do |lang|
          l = accepted_locale(split_lang(lang.first).to_sym)
          return l unless l.nil?
        end
      end

      split_lang(langs.first.first)
    end

    # TODO: Write notes
    #
    def split_lang(lang)
      return if lang.nil?

      lang.split("-").first
    end

    # TODO: Write notes
    #
    def default_locale
      I18n.default_locale
    end

    # TODO: Write notes
    #
    def check_accepted?
      @options[:accepted_locales].count.positive?
    end
  end
end
