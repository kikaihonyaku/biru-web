# Load the rails application
require File.expand_path('../application', __FILE__)
require 'openssl'

# Initialize the rails application
BiruWeb::Application.initialize!

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE