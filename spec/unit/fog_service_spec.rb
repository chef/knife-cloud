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

  pending "creates a connection to fog service with the provided auth params." do
    @instance = Chef::Knife::Cloud::FogService.new
    Fog::Compute.should_receive(:new).and_raise(Excon::Errors::Unauthorized)
    @instance.ui.should_receive(:fatal)
    expect {@instance.connection}.to raise_error(Excon::Errors::Unauthorized)
  end

end
