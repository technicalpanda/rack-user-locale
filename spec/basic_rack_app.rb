# frozen_string_literal: true

class BasicRackApp
  def call(_env)
    [200, { "Content-Type" => "text/plain" }, "Locale: #{I18n.locale}"]
  end
end
