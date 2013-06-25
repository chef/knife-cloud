# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'spec_helper'
require 'chef/knife/cloud/server/delete_command'

describe Chef::Knife::Cloud::ServerDeleteCommand do

  before do
    # setup dummy app and service objects.
    @app = App.new
    @service = Object.new
    @instance = Chef::Knife::Cloud::ServerDeleteCommand.new(@app, @service)
  end

  it "should expect compulsory properties to be set" do
    expect {Chef::Knife::Cloud::ServerDeleteCommand.new}.to raise_error
  end

  it "should raise exception to override exec_command" do
    expect {@instance.run}.to raise_error(Chef::Exceptions::Override, "You must override exec_command in #{@instance.to_s} for server deletion.")
  end

  it 'should call after_handler to delete server from chef' do
    @instance.should_receive(:after_handler)
    @instance.stub(:exec_command)
    @instance.run
  end

  it 'should expect chef warning message when purge option is disabled' do
    @app.config[:purge] = false
    @instance.server_name = "cloud-node-name"
    @instance.ui.should_receive(:warn).with("Corresponding node and client for the #{@instance.server_name} server were not deleted and remain registered with the Chef Server")
    @instance.stub(:exec_command)
    @instance.run
  end

  it 'should delete chef node and client when purge option is enabled' do
    @app.config[:purge] = true
    @instance.server_name = "cloud-node-name"
    dummy = Object.new
    dummy.stub(:destroy)
    Chef::Node.stub(:load).and_return(dummy)
    @instance.ui.should_receive(:warn).with("Deleted node #{@instance.server_name}")
    Chef::ApiClient.stub(:load).and_return(dummy)
    @instance.ui.should_receive(:warn).with("Deleted client #{@instance.server_name}")
    @instance.stub(:exec_command)
    @instance.run
  end

  it 'should delete chef node specified with node-name option overriding the instance server_name' do
    @app.config[:purge] = true
    @app.config[:chef_node_name] = 'chef-node'
    @instance.server_name = 'instance-id'
    dummy = Object.new
    dummy.stub(:destroy)
    Chef::Node.stub(:load).and_return(dummy)
    @instance.ui.should_receive(:warn).with("Deleted node #{@app.config[:chef_node_name]}")
    Chef::ApiClient.stub(:load).and_return(dummy)
    @instance.ui.should_receive(:warn).with("Deleted client #{@app.config[:chef_node_name]}")
    @instance.stub(:exec_command)
    @instance.run
  end
end
