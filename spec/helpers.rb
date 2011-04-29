require "uuidtools"
require "digest/md5"

module Helpers
  def generate_hash(secret_key, api_key, hash = {})
    auth_code = Digest::MD5.hexdigest(hash.sort.collect { |e| e * "=" } * "" << secret_key)
    Hash[hash.collect { |k, v| [api_key + "_" + k, v] }].merge!(api_key => auth_code)
  end
  def generate_cookie(secret_key, api_key, hash = {})
    generate_hash(secret_key, api_key, hash).collect { |(k, v)| "#{k}=#{v}" }
  end
end
