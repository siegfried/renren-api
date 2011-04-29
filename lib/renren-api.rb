module RenrenAPI

  VERSION = [0, 3, 2]

  def self.version
    VERSION * "."
  end

  autoload :Authentication, "renren-api/authentication"
  autoload :SignatureCalculator, "renren-api/signature_calculator"
  autoload :HTTPAdapter, "renren-api/http_adapter"

end
