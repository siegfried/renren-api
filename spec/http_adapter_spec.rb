require_relative "../lib/renren-api/http_adapter"
require_relative "../lib/renren-api/signature_calculator"
require "json"
require "net/http"
require "zlib"
require "stringio"

describe RenrenAPI::HTTPAdapter, "#get_friends" do
  subject { described_class.new(http, api_key, secret_key, session_key).get_friends }
  let(:http) { Net::HTTP.new("api.renren.com") }
  let(:api_key) { "8802f8e9b2cf4eb993e8c8adb1e02b06" }
  let(:secret_key) { "34d3d1e26cd44c05a0c450c0a0f8147b" }
  let(:session_key) { "session_key" }
  let(:result) do
    [
      {"id" => 12345, "name" => "Levin", "tinyurl" => "http://renren.com/1.jpg"},
      {"id" => 12346, "name" => "James", "tinyurl" => "http://renren.com/2.jpg"}
    ]
  end
  let!(:now) do
    Time.now
  end
  let(:params) do
    {
      :api_key => api_key,
      :method => "friends.getFriends",
      :call_id => "%.3f" % now.to_f,
      :v => "1.0",
      :session_key => session_key,
      :format => "JSON"
    }
  end
  let(:form_params) do
    signature_calculator = RenrenAPI::SignatureCalculator.new(secret_key)
    signature = signature_calculator.calculate(params)
    URI.encode_www_form(params.merge(:sig => signature))
  end
  before :each do
    Time.stub(:now).and_return(now)
    response = mock(Net::HTTPResponse)
    gzip_writer = Zlib::GzipWriter.new(StringIO.new(buffer = ""))
    gzip_writer << JSON.generate(result)
    gzip_writer.close
    response.stub(:code => '200', :message => "OK", :content_type => "application/json", :body => buffer)
    http.should_receive(:post).with("/restserver.do", form_params, {"Accept-Encoding" => "gzip"}).once.and_return(response)
  end
  it { should == result }
end

describe RenrenAPI::HTTPAdapter, "#get_info" do
  subject { described_class.new(http, api_key, secret_key, session_key).get_info(uids, fields) }
  let(:http) { Net::HTTP.new("api.renren.com") }
  let(:api_key) { "8802f8e9b2cf4eb993e8c8adb1e02b06" }
  let(:secret_key) { "34d3d1e26cd44c05a0c450c0a0f8147b" }
  let(:session_key) { "session_key" }
  let(:result) do
    [
      {"uid" => 12345, "name" => "Levin", "tinyurl" => "http://renren.com/1.jpg"},
      {"uid" => 12346, "name" => "James", "tinyurl" => "http://renren.com/2.jpg"}
    ]
  end
  let!(:now) do
    Time.now
  end
  let(:fields) do
    %w{uid name tinyurl}
  end
  let(:uids) do
    [12345, 12346]
  end
  let(:params) do
    {
      :api_key => api_key,
      :method => "users.getInfo",
      :call_id => "%.3f" % now.to_f,
      :v => "1.0",
      :session_key => session_key,
      :fields => fields * ",",
      :uids => uids * ",",
      :format => "JSON"
    }
  end
  let(:form_params) do
    signature_calculator = RenrenAPI::SignatureCalculator.new(secret_key)
    signature = signature_calculator.calculate(params)
    URI.encode_www_form(params.merge(:sig => signature))
  end
  before :each do
    Time.stub(:now).and_return(now)
    response = mock(Net::HTTPResponse)
    gzip_writer = Zlib::GzipWriter.new(StringIO.new(buffer = ""))
    gzip_writer << JSON.generate(result)
    gzip_writer.close
    response.stub(:code => '200', :message => "OK", :content_type => "application/json", :body => buffer)
    http.should_receive(:post).with("/restserver.do", form_params, {"Accept-Encoding" => "gzip"}).once.and_return(response)
  end
  it { should == result }
end

describe RenrenAPI::HTTPAdapter, "#send_notification" do
  subject { described_class.new(http, api_key, secret_key, session_key).send_notification(receiver_ids, notification) }
  let(:http) { Net::HTTP.new("api.renren.com") }
  let(:api_key) { "8802f8e9b2cf4eb993e8c8adb1e02b06" }
  let(:secret_key) { "34d3d1e26cd44c05a0c450c0a0f8147b" }
  let(:session_key) { "session_key" }
  let(:result) do
    {"result" => 1}
  end
  let!(:now) do
    Time.now
  end
  let(:receiver_ids) do
    [12345, 12346]
  end
  let(:params) do
    {
      :api_key => api_key,
      :method => "notifications.send",
      :call_id => "%.3f" % now.to_f,
      :v => "1.0",
      :session_key => session_key,
      :format => "JSON",
      :to_ids => receiver_ids * ",",
      :notification => notification
    }
  end
  let(:notification) do
    "test"
  end
  let(:form_params) do
    signature_calculator = RenrenAPI::SignatureCalculator.new(secret_key)
    signature = signature_calculator.calculate(params)
    URI.encode_www_form(params.merge(:sig => signature))
  end
  before :each do
    Time.stub(:now).and_return(now)
    response = mock(Net::HTTPResponse)
    gzip_writer = Zlib::GzipWriter.new(StringIO.new(buffer = ""))
    gzip_writer << JSON.generate(result)
    gzip_writer.close
    response.stub(:code => '200', :message => "OK", :content_type => "application/json", :body => buffer)
    http.should_receive(:post).with("/restserver.do", form_params, {"Accept-Encoding" => "gzip"}).once.and_return(response)
  end
  it { should == result }
end
