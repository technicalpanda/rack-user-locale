# frozen_string_literal: true

class BasicRackApp
  def call(_env)
    [200, { "Content-Type" => "text/plain" }, "Hello World"]
  end
end
