$:.unshift File.expand_path('../../lib', __FILE__)
require 'chef/knife/cloud/exceptions'

class App
  attr_accessor :config
  def initialize
    @config = {}
  end
end
