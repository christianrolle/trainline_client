# frozen_string_literal: true

Rails.application.config.after_initialize do
  Faraday::Middleware.register_middleware trainline: Trainline::Middleware
end
