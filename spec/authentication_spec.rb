require_relative "../lib/renren-api/authentication"
require "rack/test"
require "helpers"

class Rack::MockResponse
  def unauthorized?
    @status == 401
  end
end

describe RenrenAPI::Authentication do
  include Rack::Test::Methods
  include Helpers
  def app
    RenrenAPI::Authentication.new(lambda { |env| [200, {}, ["OK"]] }, "8802f8e9b2cf4eb993e8c8adb1e02b06", "34d3d1e26cd44c05a0c450c0a0f8147b") do |env|
      [401, {}, ["Get out of #{env["PATH_INFO"]}!"]]
    end
  end
  subject { request(path, @env); last_response }
  before { @env = {} }

  context "when path does not have prefix /people/{person-id}" do
    let(:path) { "/" }
    %w{GET POST PUT DELETE}.each do |m|
      context(m) do
        before { @env[:method] = m }
        it { should be_ok }
        its(:body) { should == "OK" }
      end
    end
  end

  context "when path has prefix /people/{person-id}" do
    let(:path) { "/people/#{person_id}" }
    let(:person_id) { rand(9999).to_s }
    context "when no login information provided" do
      %w{GET POST PUT DELETE}.each do |m|
        context(m) do
          before { @env[:method] = m }
          it { should be_unauthorized }
          its(:body) { should == "Get out of #{path}!" }
        end
      end
    end
    context "when correct login information provided" do
      before { @env[:cookie] = generate_cookie(secret_key, api_key, hash) }
      let(:secret_key) { "34d3d1e26cd44c05a0c450c0a0f8147b" }
      let(:api_key) { "8802f8e9b2cf4eb993e8c8adb1e02b06" }
      let(:hash) do
        {
          "user" => person_id,
          "session_key" => "session_key",
          "ss" => "session_key_secret",
          "expires" => (Time.now.to_i + rand(9999) + 1).to_s
        }
      end
      %w{GET POST PUT DELETE}.each do |m|
        context(m) do
          before { @env[:method] = m }
          it { should be_ok }
          its(:body) { should == "OK" }
        end
      end
    end
    context "when incorrect login information provided" do
      before { @env[:cookie] = generate_cookie("xxxx", api_key, hash) }
      let(:api_key) { "8802f8e9b2cf4eb993e8c8adb1e02b06" }
      let(:hash) do
        {
          "user" => person_id,
          "session_key" => "session_key",
          "ss" => "session_key_secret",
          "expires" => (Time.now.to_i + rand(9999) + 1).to_s
        }
      end
      %w{GET POST PUT DELETE}.each do |m|
        context(m) do
          before { @env[:method] = m }
          it { should be_unauthorized }
          its(:body) { should == "Get out of #{path}!" }
        end
      end
    end
  end

end

describe RenrenAPI::Authentication, "no failed handler is provided" do
  include Rack::Test::Methods
  include Helpers
  def app
    RenrenAPI::Authentication.new(lambda { |env| [200, {}, ["OK"]] }, "8802f8e9b2cf4eb993e8c8adb1e02b06", "34d3d1e26cd44c05a0c450c0a0f8147b")
  end
  subject { request(path, @env); last_response }
  before { @env = {} }

  context "when path does not have prefix /people/{person-id}" do
    let(:path) { "/" }
    %w{GET POST PUT DELETE}.each do |m|
      context(m) do
        before { @env[:method] = m }
        it { should be_ok }
        its(:body) { should == "OK" }
      end
    end
  end

  context "when path has prefix /people/{person-id}" do
    let(:path) { "/people/#{person_id}" }
    let(:person_id) { rand(9999).to_s }
    context "when no login information provided" do
      %w{GET POST PUT DELETE}.each do |m|
        context(m) do
          before { @env[:method] = m }
          it { should be_unauthorized }
          its(:content_type) { should == "text/plain"}
          its(:body) { should == "Unauthorized!" }
        end
      end
    end
    context "when correct login information provided" do
      before { @env[:cookie] = generate_cookie(secret_key, api_key, hash) }
      let(:secret_key) { "34d3d1e26cd44c05a0c450c0a0f8147b" }
      let(:api_key) { "8802f8e9b2cf4eb993e8c8adb1e02b06" }
      let(:hash) do
        {
          "user" => person_id,
          "session_key" => "session_key",
          "ss" => "session_key_secret",
          "expires" => (Time.now.to_i + rand(9999) + 1).to_s
        }
      end
      %w{GET POST PUT DELETE}.each do |m|
        context(m) do
          before { @env[:method] = m }
          it { should be_ok }
          its(:body) { should == "OK" }
        end
      end
    end
    context "when incorrect login information provided" do
      before { @env[:cookie] = generate_cookie("xxxx", api_key, hash) }
      let(:api_key) { "8802f8e9b2cf4eb993e8c8adb1e02b06" }
      let(:hash) do
        {
          "user" => person_id,
          "session_key" => "session_key",
          "ss" => "session_key_secret",
          "expires" => (Time.now.to_i + rand(9999) + 1).to_s
        }
      end
      %w{GET POST PUT DELETE}.each do |m|
        context(m) do
          before { @env[:method] = m }
          it { should be_unauthorized }
          its(:content_type) { should == "text/plain" }
          its(:body) { should == "Unauthorized!" }
        end
      end
    end
  end

end
