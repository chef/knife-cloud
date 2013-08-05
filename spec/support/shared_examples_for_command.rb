# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'chef/knife/cloud/command'
require 'chef/knife/cloud/service'

shared_examples_for Chef::Knife::Cloud::Command do |instance|
  it "runs with correct method calls" do
    instance.stub(:execute_command)
    instance.stub(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
    instance.should_receive(:validate!).ordered
    instance.should_receive(:validate_params!).ordered
    instance.should_receive(:create_service_instance).ordered
    instance.should_receive(:before_exec_command).ordered
    instance.should_receive(:execute_command).ordered
    instance.should_receive(:after_exec_command).ordered
    instance.run
  end


  it "cleanup on any error" do
    instance.stub(:execute_command).and_raise(Chef::Knife::Cloud::CloudExceptions)
    instance.stub(:after_exec_command)
    instance.ui.stub(:fatal)
    instance.stub(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
    instance.should_receive(:cleanup_on_failure)
    instance.run
  end     
end
