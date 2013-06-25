# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'chef/knife/cloud/fog/server_create_command'

describe Chef::Knife::Cloud::FogServerCreateCommand do
  before do
    @app = App.new
    @service = Object.new
    @instance = Chef::Knife::Cloud::FogServerCreateCommand.new(@app, @service)
  end

  it "asks for compulsory properties while creating instance" do
    expect {Chef::Knife::Cloud::FogServerCreateCommand.new}.to raise_error(ArgumentError)
  end

end
