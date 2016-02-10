ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Deactivate authentication mechanism for the tests
  ApplicationController.skip_before_action :api_authenticate
end
