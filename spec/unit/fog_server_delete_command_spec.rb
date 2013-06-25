# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'spec_helper'
require 'chef/knife/cloud/fog/server_delete_command'

describe Chef::Knife::Cloud::FogServerDeleteCommand do

  before do
    # setup dummy app and service objects.
    @app = App.new
    @service = Object.new
    @instance = Chef::Knife::Cloud::FogServerDeleteCommand.new(@app, @service)
  end

  it "should expect compulsory properties to be set" do
    expect {Chef::Knife::Cloud::FogServerDeleteCommand.new}.to raise_error
  end

end
