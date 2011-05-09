require_relative "signature_calculator"
require "uri"
require "zlib"
require "json"

module RenrenAPI
  class HTTPAdapter
    def initialize(http, api_key, secret_key, session_key)
      @http, @api_key, @secret_key, @session_key = http, api_key, secret_key, session_key
      @signature_calculator = SignatureCalculator.new(@secret_key)
    end
    def get_friends
      params = {
        :api_key => @api_key,
        :method => "friends.getFriends",
        :call_id => current_time_in_millisecond,
        :v => "1.0",
        :session_key => @session_key,
        :format => "JSON"
      }
      request(params)
    end
    def get_info(uids, fields)
      params = {
        :api_key => @api_key,
        :method => "users.getInfo",
        :call_id => current_time_in_millisecond,
        :v => "1.0",
        :session_key => @session_key,
        :fields => fields * ",",
        :uids => uids * ",",
        :format => "JSON"
      }
      request(params)
    end
    def send_notification(receiver_ids, notification)
      request(
        :api_key => @api_key,
        :method => "notifications.send",
        :call_id => current_time_in_millisecond,
        :v => "1.0",
        :session_key => @session_key,
        :format => "JSON",
        :to_ids => receiver_ids * ",",
        :notification => notification
      )
    end
    private
    def current_time_in_millisecond
      "%.3f" % Time.now.to_f
    end
    def request(params)
      params[:sig] = @signature_calculator.calculate(params)
      response = @http.post("/restserver.do", URI.encode_www_form(params), {"Accept-Encoding" => "gzip"})
      gzip_reader = Zlib::GzipReader.new(StringIO.new(response.body))
      result = JSON.parse(gzip_reader.read)
      gzip_reader.close
      result
    end
  end
end
