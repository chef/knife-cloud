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
      Fog::Compute.should_receive(:new).with({:provider => 'Any Cloud Provider'})
      instance.connection
    end

  end
end
