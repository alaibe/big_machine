# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

module ActiveRecord
  class Base

    cattr_accessor :after_initialize_method
    def self.after_initialize(method)
      @@after_initialize_method = method 
    end

    def self.new(*args, &blk)
      o = allocate
      o.send :initialize, *args, &blk
      o.send o.class.after_initialize_method
      o
    end

    def save!
      true
    end
  end
end