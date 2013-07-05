# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'chef/knife/cloud/fog/service'

describe Chef::Knife::Cloud::FogService do

  let (:instance) { Chef::Knife::Cloud::FogService.new }

  it { expect {instance}.to_not raise_error }

  it "creates a connection to fog service." do
    @instance = Chef::Knife::Cloud::FogService.new
    Fog::Compute.should_receive(:new)
    @instance.connection
  end

  it "creates a connection to fog service with the provided auth params." do
    @instance = Chef::Knife::Cloud::FogService.new({:auth_params => {:provider => 'Any Cloud Provider'}})
    Fog::Compute.should_receive(:new).with({:provider => 'Any Cloud Provider'})
    @instance.connection
  end

  it "throws error message when incorrect auth params are provided." do
    error_message = "Connection failure, please check your username and password."
    @instance = Chef::Knife::Cloud::FogService.new({:auth_params => {:provider => 'Any Cloud Provider'}})
    Fog::Compute.should_receive(:new).with({:provider => 'Any Cloud Provider'}).and_raise(Excon::Errors::Unauthorized.new(error_message))
    @instance.stub_chain(:ui, :fatal).with(error_message)
    lambda { @instance.connection }.should raise_error(SystemExit)
  end

  pending "throws error message when there is any socket error." do
    error_message = "Connection failure, please check your authentication URL."
    @instance = Chef::Knife::Cloud::FogService.new({:auth_params => {:provider => 'Any Cloud Provider', :connection_options => 'proxy_opts'}})
    Fog::Compute.should_receive(:new).with({:provider => 'Any Cloud Provider', :connection_options => 'proxy_opts'}).and_raise(Excon::Errors::SocketError.new(error_message))
    @instance.stub_chain(:ui, :fatal).with(error_message)
    lambda { @instance.connection }.should raise_error(SystemExit)
  end

  context "delete" do
    it "deletes the server." do
      @server = mock()
      instance.stub(:puts)
      instance.stub_chain(:connection, :servers, :get).and_return(@server)
      @server.should_receive(:name).ordered
      @server.should_receive(:id).ordered
      instance.stub_chain(:ui, :confirm).ordered
      @server.should_receive(:destroy).ordered
      instance.delete_server(:server_name)
    end

    it "throws error message when the server cannot be located." do
      server_name = "invalid_server_name"
      error_message = "Could not locate server '#{server_name}'."
      instance.stub_chain(:connection, :servers, :get).and_return(nil)
      instance.stub_chain(:ui, :error).with(error_message)
      expect { instance.delete_server(server_name) }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServerDeleteError)
    end

    pending "throws error message when it returns an unknown server error." do
      server_name = "invalid_server_name"
      error_message = "Unknown server error (#{}): #{}"
      instance.stub(:response)
      instance.stub_chain(:connection, :servers, :get).and_raise(Excon::Errors::BadRequest.new(error_message))
      # instance.stub_chain(:ui, :fatal).with(error_message)
      expect { @instance.delete_server(server_name) }.to raise_error(Excon::Errors::BadRequest)
    end
  end

  context "create" do
    pending "creates the server." do

    end
  end

end
