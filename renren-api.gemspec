Gem::Specification.new do |spec|
  spec.name = "renren-api"
  spec.version = "0.3.4"
  spec.summary = "a library to request Renren's API"
  spec.description = <<-EOF
  renren-api provides capability to request the service of Renren Social Network.
  EOF
  spec.files = Dir["{lib/**/*,spec/*}"] + %w{README}
  spec.require_path = "lib"
  spec.extra_rdoc_files = %w{README}
  spec.test_files = Dir["spec/*_spec.rb"]
  spec.author = "Lei, Zhi-Qiang"
  spec.email = "zhiqiang.lei@gmail.com"
  spec.homepage = "https://github.com/siegfried/renren-api"
  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = ">= 1.9.2"
  spec.license = "BSD"
end
