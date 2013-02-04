require 'i18n'

module Rack
  class UserLocale

    def initialize(app)
      @app = app
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
        response.set_cookie('locale', {
          :value => I18n.locale,
          :path => '/',
          :domain => @request.host}) if get_cookie_locale != I18n.locale.to_s
        response.finish
      end
    end

    private

    def set_locale
      I18n.locale = @env['rack.locale'] = locale.to_sym
    end

    def locale
      get_cookie_locale || get_browser_locale || get_default_locale
    end

    def get_cookie_locale
      @request.cookies['locale']
    end

    def get_browser_locale
      accept_langs = @env["HTTP_ACCEPT_LANGUAGE"]
      return if accept_langs.nil?

      languages_and_qvalues = accept_langs.split(",").map { |l|
        l += ';q=1.0' unless l =~ /;q=\d+(?:\.\d+)?$/
        l.split(';q=')
      }

      lang = languages_and_qvalues.sort_by { |(locale, qvalue)|
        qvalue.to_f
      }.last.first

      lang == '*' ? nil : lang
    end

    def get_default_locale
      I18n.default_locale
    end
  end
end