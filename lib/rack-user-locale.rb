require "i18n"

module Rack
  class UserLocale

    def initialize(app, options = {})
      @app, @options = app, {
          :accepted_locales => []
        }.merge(options)
    end

    def call(env)
      @env = env
      @request = Rack::Request.new(@env)
      set_locale

      if @request.post? || @request.put? || @request.delete?
        @app.call(env)
      else
        status, headers, body = @app.call(@env)
        response = Rack::Response.new(body, status, headers)
        response.set_cookie("user-locale", {
          :value => I18n.locale,
          :path => "/",
          :domain => @request.host}) if get_cookie_locale != I18n.locale.to_s
        response.finish
      end
    end

    private

    def set_locale
      new_locale = check_accepted? ? accepted_locale(locale.to_sym, get_default_locale) : locale.to_sym
      I18n.locale = @env["rack.locale"] = new_locale
    end

    def accepted_locale(locale, other_locale = nil)
      locale = @options[:accepted_locales].include?(locale) ? locale : other_locale
    end

    def locale
      get_cookie_locale || get_browser_locale || get_default_locale
    end

    def get_cookie_locale
      @request.cookies["user-locale"]
    end

    def get_browser_locale
      accept_lang = @env["HTTP_ACCEPT_LANGUAGE"]
      return if accept_lang.nil?

      langs = accept_lang.split(",").map { |l|
        l += ';q=1.0' unless l =~ /;q=\d+\.\d+$/
        l.split(';q=')
      }.sort { |a, b| b[1] <=> a[1] }

      if check_accepted?
        langs.each do |lang|
          l = accepted_locale(split_lang(lang.first).to_sym)
          return l unless l.nil?
        end
      end

      return split_lang(langs.first.first)
    end

    def split_lang(lang)
      lang.split("-").first unless lang.nil?
    end

    def get_default_locale
      I18n.default_locale
    end

    def check_accepted?
      @options[:accepted_locales].count > 0
    end
  end
end