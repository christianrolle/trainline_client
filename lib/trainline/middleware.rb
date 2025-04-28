# frozen_string_literal: true

module Trainline
  class Middleware
    DEFAULT_HEADERS = {
      'Accept' => 'application/json',
      'Content-Type' => 'text/plain;charset=UTF-8',
      'User-Agent' => 'Mozilla/5.0',
      'x-version' => '4.42.30718' # anti bot "logic"
    }.freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      env.request_headers.merge! DEFAULT_HEADERS

      response = @app.call(env).on_complete do |request|
        log(request) unless request.success?
      end
    rescue Faraday::Error => e
      log(e)
    end

    private

    def log(message)
      Rails.logger.error "Trainline API: #{message.inspect}"
    end
  end
end
