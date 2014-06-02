# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'chef/knife/cloud/fog/service'
require 'support/shared_examples_for_service'

describe Chef::Knife::Cloud::FogService do

  it_behaves_like Chef::Knife::Cloud::Service, Chef::Knife::Cloud::FogService.new

  let (:instance) { Chef::Knife::Cloud::FogService.new({:auth_params => {:provider => 'Any Cloud Provider'}}) }

  context "connection" do
    before do
      instance.stub(:exit)
    end

    it "creates a connection to fog service with the provided auth params." do
      instance.should_receive(:add_api_endpoint)
      Fog::Compute.should_receive(:new).with({:provider => 'Any Cloud Provider'})
      instance.connection
    end
  end

  context "network" do
    it "creates a connection to fog network with the provided auth params." do
      Fog::Network.should_receive(:new).with({:provider => 'Any Cloud Provider'})
      instance.network
    end

    context "connection to fog" do
      before do
        instance.stub(:exit)
        instance.stub(:ui).and_return(Object.new)
        instance.ui.should_receive(:fatal)
      end

      it "handles Unauthorized exception." do
        Fog::Network.should_receive(:new).with({:provider => 'Any Cloud Provider'}).and_raise Excon::Errors::Unauthorized.new("Unauthorized")
        expect {instance.network}.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServiceConnectionError)
      end

      it "handles SocketError or any other connection exception." do
        socket_error = Excon::Errors::SocketError.new(Exception.new "Mock Error")
        Fog::Network.should_receive(:new).with({:provider => 'Any Cloud Provider'}).and_raise socket_error
        expect {instance.network}.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServiceConnectionError)
      end

      it "handles NetworkNotFoundError exception." do
        Fog::Network.should_receive(:new).with({:provider => 'Any Cloud Provider'}).and_raise Fog::Errors::NotFound.new("NotFound")
        expect {instance.network}.to raise_error(Chef::Knife::Cloud::CloudExceptions::NetworkNotFoundError)
      end
    end
  end

  context "add_custom_attributes" do
    before(:each) do
      Chef::Config[:knife][:custom_attributes] = [{"state"=>"Inactive"}]
      @server_def = {:name=>"vm-1", :image_ref=>"123",:flavor_ref=>"2", :key_name=>"key"}
      instance.add_custom_attributes(@server_def)
    end

    it "adds the custom attributes provided to server_def" do
      expect(@server_def.include?(:state)).to be true
    end

    it "sets the provided attributes with supplied values" do
      expect(@server_def[:state] == "Inactive").to be true
    end 
  end

  ["servers", "images", "networks"].each do |resource_type|
    resource =  case resource_type
                when "networks"
                  :network
                else
                  :connection
                end
    context "list #{resource_type}" do
      
      it "lists #{resource_type} of the current cloud service provider account." do
        instance.stub_chain(resource.to_sym, "#{resource_type}".to_sym, :all) 
        instance.method("list_#{resource_type}").call
      end

      it "handles Excon::Errors::BadRequest exception." do
        instance.stub(:ui).and_return(Object.new)
        instance.ui.should_receive(:fatal)
        instance.stub_chain(resource.to_sym, "#{resource_type}".to_sym, :all).and_raise Excon::Errors::BadRequest.new("Invalid Resource")
        expect {instance.method("list_#{resource_type}").call}.to raise_error(Chef::Knife::Cloud::CloudExceptions::CloudAPIException)
      end
    end
  end

  context "#delete_server" do
    before(:each) do
      @server = TestResource.new({:id => "test-server1"})
      @server.define_singleton_method(:destroy){}
    end

    it "delete instance successfully" do
      server_name = "test-server1"
      instance.ui = double
      instance.should_receive(:get_server).and_return(@server)
      instance.should_receive(:get_server_name).and_return(server_name)
      instance.should_receive(:msg_pair).with("Instance Name", server_name)
      instance.should_receive(:msg_pair).with("Instance ID", @server.id)
      instance.ui.should_receive(:confirm)
      @server.should_receive(:destroy)
      instance.delete_server(server_name)
    end

    it "raise_error on non existence server delete " do
      server_name = "test-server1"
      instance.ui = double
      error_message = "Could not locate server '#{server_name}'."
      instance.should_receive(:get_server).and_return(nil)
      instance.ui.should_receive(:error).with(error_message)
      expect { instance.delete_server(server_name) }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServerDeleteError, error_message)
    end
  end
end
