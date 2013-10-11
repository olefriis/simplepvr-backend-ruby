ENV['RACK_ENV'] = 'test'
require 'capybara'
require 'capybara/cucumber'
require 'capybara/poltergeist'
require 'rspec'

require File.join(File.dirname(__FILE__), '../../lib/simple_pvr')

SimplePvr::PvrInitializer.setup_for_integration_test
SimplePvr::RecordingPlanner.reload

Capybara.app = eval "Rack::Builder.new {( " + SimplePvr::PvrInitializer.rack_maps_file + ")}"
Capybara.default_driver = (ENV['capybara_driver'] || 'poltergeist').to_sym # 'selenium' can be nice too
Capybara.default_wait_time = 30

class SimplePvrWorld
  include Capybara::DSL
  include RSpec::Expectations
  include RSpec::Matchers
end

World do
  SimplePvrWorld.new
end

Before do
  SimplePvr::Model::DatabaseInitializer.clear
end
