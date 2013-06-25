$:.unshift File.expand_path('../../lib', __FILE__)
require 'chef/exceptions'
require 'json'

class App
  attr_accessor :config
  def initialize
    @config = {}
  end
end

# TODO - we should use factory girl or fixtures for this as part of test utils.
# Creates a resource class that can dynamically add attributes to
# instances and set the values
module JSONModule
  def to_json
    hash = {}
    self.instance_variables.each do |var|
      hash[var] = self.instance_variable_get var
    end
    hash.to_json
  end
  def from_json! string
    JSON.load(string).each do |var, val|
      self.instance_variable_set var, val
    end
  end
end

class TestResource
  include JSONModule
  def initialize(*args)
    args.each do |arg|
      arg.each do |key, value|
        add_attribute = "class << self; attr_accessor :#{key}; end"
        eval(add_attribute)
        eval("@#{key} = value")
      end
    end
  end
end
