require "digest/md5"

module RenrenAPI
  class SignatureCalculator
    def initialize(secret_key)
      @secret_key = secret_key
    end
    def calculate(hash)
      Digest::MD5.hexdigest(hash.collect { |(k, v)| "#{k}=#{v}" }.sort * "" << @secret_key)
    end
  end
end
