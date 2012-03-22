require "bundler"
Bundler.require :default, :development

require "savon-multipart"

# Disable logging and deprecations for specs.
Savon.configure do |config|
  config.log = false
  # config.deprecate = false
end
