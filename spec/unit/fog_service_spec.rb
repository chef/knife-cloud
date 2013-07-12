# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'chef/knife/cloud/fog/service'
require 'support/shared_examples_for_fog_service'

describe Chef::Knife::Cloud::FogService do

  it_behaves_like Chef::Knife::Cloud::FogService, Chef::Knife::Cloud::FogService.new

  let (:instance) { Chef::Knife::Cloud::FogService.new }

  it { expect {instance}.to_not raise_error }

  describe "#initialize" do
    Chef::Config[:knife][:cloud_fog_version] = '1.12.1'
    test_instance = Chef::Knife::Cloud::FogService.new
    test_instance.fog_version.should == '1.12.1'
  end

  context "connection" do
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
  end
end
