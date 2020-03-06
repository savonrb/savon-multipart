lib = File.expand_path("../lib", __FILE__)
$:.unshift lib unless $:.include? lib

require "savon/multipart/version"

Gem::Specification.new do |s|
  s.name        = "savon-multipart"
  s.version     = Savon::Multipart::VERSION
  s.authors     = ["Martin Westin", "Daniel Harrington"]
  s.email       = ["martin@eimermusic.com", "me@rubiii.com"]
  s.homepage    = "http://savonrb.com"
  s.summary     = "Heavy metal Ruby SOAP client with multipart support"
  s.description = "Adds multipart support (SOAP with Attachments) to Savon"
  s.required_ruby_version = '>= 1.9.2'

  s.rubyforge_project = s.name

  s.add_dependency "savon", "~> 2"
  s.add_dependency "mail", "~> 2"

  s.add_development_dependency "rake"
  s.add_development_dependency "pry"
  s.add_development_dependency "rspec"
  s.add_development_dependency "autotest"
  s.add_development_dependency "transpec"

  s.files = `git ls-files`.split("\n")
  s.require_path = "lib"
end
