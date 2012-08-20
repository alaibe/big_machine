require 'big_machine'
require 'test/unit'

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