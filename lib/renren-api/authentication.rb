require "rack"
require_relative "signature_calculator"

module RenrenAPI
  class Authentication
    def initialize(app, api_key, secret_key, &failed_handler)
      @app = app
      @api_key = api_key
      @secret_key = secret_key
      @signature_calculator = SignatureCalculator.new(@secret_key)
      @required_keys = %w{user session_key ss expires}.collect { |e| @api_key + "_" + e } << @api_key
      @failed_handler = block_given? ? failed_handler : proc { [401, {"Content-Type" => "text/plain"}, ["Unauthorized!"]] }
    end
    def call(env)
      request = Rack::Request.new(env)
      if %r{^/people/(?<person_id>\d+)} =~ request.path_info
        cookies = request.cookies
        if valid?(cookies) && cookies["#{@api_key}_user"] == person_id
          @app.call(env)
        else
          @failed_handler.call(env)
        end
      else
        @app.call(env)
      end
    end
    private
    def valid?(cookies)
      @required_keys.each do |k|
        return false unless cookies.has_key?(k)
      end
      return false if cookies["#{@api_key}_expires"].to_i < Time.now.to_i
      cookies[@api_key] == @signature_calculator.calculate(filter(cookies))
    end
    def filter(cookies)
      hash = {}
      %w{user session_key ss expires}.each { |e| hash[e] = cookies["#{@api_key}_#{e}"] }
      hash
    end
  end
end
