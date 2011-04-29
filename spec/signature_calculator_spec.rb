require_relative "../lib/renren-api/signature_calculator"

describe RenrenAPI::SignatureCalculator do
  let(:calculator) { RenrenAPI::SignatureCalculator.new(secret_key) }
  describe "#calculate" do
    subject { calculator.calculate(hash) }
    context "when secret_key is 7fbf9791036749cb82e74efd62e9eb38" do
      let(:secret_key) { "7fbf9791036749cb82e74efd62e9eb38" }
      example_hash = {
        "v" => "1.0",
        "api_key" => "ec9e57913c5b42b282ab7b743559e1b0",
        "method" => "xiaonei.users.getLoggedInUser",
        "call_id" => 1232095295656,
        "session_key" => "L6Xe8dXVGISZ17LJy7GzZaeYGpeGfeNdqEPLNUtCJfxPCxCRLWT83x+s/Ur94PqP-700001044"
      }
      context "when hash is #{example_hash.inspect}" do
        let(:hash) { example_hash }
        it { should == "66f332c08191b8a5dd3477d36f3af49f" }
      end
    end
  end
end
