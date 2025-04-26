# frozen_string_literal: true

module Trainline
  class Middleware
    DEFAULT_HEADERS = {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'User-Agent' => 'Friend',
    }.freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      env.request_headers.merge! DEFAULT_HEADERS

      response = @app.call(env).on_complete do |request|
        log(request) unless request.success?
      end
      JSON.parse response.body
    rescue Faraday::TimeoutError
      log('Timeout')
    rescue Faraday::Error => e
      log(e)
    rescue JSON::ParserError => e
      log("Parsing #{e.message} failed")
    end

    private

    def log(message)
      Rails.logger.error "Trainline API: #{message.inspect}"
    end
  end
end
