# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'spec_helper'
require 'chef/knife/cloud/fog/server_delete_command'

describe Chef::Knife::Cloud::FogServerDeleteCommand do

  before do
    # setup dummy app and service objects.
    @app = App.new
    @service = Object.new
    @instance = Chef::Knife::Cloud::FogServerDeleteCommand.new(@app, @service)
    @instance.stub(:puts)
    @instance.ui.stub(:error)
  end

  it "should expect compulsory properties to be set" do
    expect {Chef::Knife::Cloud::FogServerDeleteCommand.new}.to raise_error
  end

  it 'successfully deletes the server instance.' do
    @server = mock()
    @service.stub_chain(:connection, :servers, :get).and_return(@server)
    @server.stub(:name)
    @server.stub(:id)
    @instance.stub_chain(:ui, :confirm)
    @server.should_receive(:destroy)
    @instance.exec_command(@instance.server_name)
  end

  it 'calls after_handler to delete server from chef' do
    @instance.should_receive(:after_handler)
    @instance.stub(:exec_command)
    @instance.run
  end

  it 'raises runtime error when no server name is given to delete.' do
    expect{@instance.exec_command}.to raise_error(RuntimeError, "Could not locate server ''.")
  end

  it 'raises runtime error when any invalid server name is given to delete.' do
    @instance.server_name = "some_server"
    expect{@instance.exec_command(@instance.server_name)}.to raise_error(RuntimeError, "Could not locate server '#{@instance.server_name}'.")
  end
end
