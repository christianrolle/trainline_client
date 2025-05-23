# frozen_string_literal: true

require 'faraday'
require 'trainline/middleware'

module Trainline
  # Connection object for Trainline requests
  # It reduces boilerplate for running several requests with the same connection
  class Connection
    HOST = ENV.fetch('TRAINLINE_API_HOST', 'www.thetrainline.com')

    def self.request(resource, method: :get, params: {}, body: nil, parser: JSON, headers: {})
      path = "/api/#{resource}"
      body = body.to_json if body.present?

      response = connection.run_request(method, path, body, headers) do |req|
        req.params.update(params)
      end
      parser.parse response.body
    rescue JSON::ParserError => e
      log("Parsing #{e.message} failed")
    end

    def self.connection
      @connection ||= Faraday.new(URI::HTTPS.build host: HOST) do |conn|
        conn.use :trainline
      end
    end
  end
end
