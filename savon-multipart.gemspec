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

  s.rubyforge_project = s.name

  s.add_dependency "savon", "~> 2.3.0"
  s.add_dependency "mail"

  s.add_development_dependency "rake",    "~> 0.8.7"
  s.add_development_dependency "rspec",   "~> 2.5.0"
  s.add_development_dependency "autotest"

  s.files = `git ls-files`.split("\n")
  s.require_path = "lib"
end
