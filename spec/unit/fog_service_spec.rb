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

  ["servers", "images", "networks"].each do |iterator|
    context "list #{iterator}" do
      case iterator
      when "networks"
        it "lists #{iterator}." do
          instance.stub_chain(:network, "#{iterator}".to_sym, :all) 
          instance.method("list_#{iterator}").call
        end

        it "handles Excon::Errors::BadRequest exception." do
          instance.stub(:ui).and_return(Object.new)
          instance.ui.should_receive(:fatal)
          instance.stub_chain(:network, "#{iterator}".to_sym, :all).and_raise Excon::Errors::BadRequest.new("Invalid Network")
          expect {instance.method("list_#{iterator}").call}.to raise_error(Chef::Knife::Cloud::CloudExceptions::CloudAPIException)
        end
      else
        it "lists #{iterator}." do
          instance.stub_chain(:connection, "#{iterator}".to_sym, :all) 
          instance.method("list_#{iterator}").call
        end

        it "handles Excon::Errors::BadRequest exception." do
          instance.stub(:ui).and_return(Object.new)
          instance.ui.should_receive(:fatal)
          instance.stub_chain(:connection, "#{iterator}".to_sym, :all).and_raise Excon::Errors::BadRequest.new("Invalid Server")
          expect {instance.method("list_#{iterator}").call}.to raise_error(Chef::Knife::Cloud::CloudExceptions::CloudAPIException)
        end
      end
    end
  end
end
