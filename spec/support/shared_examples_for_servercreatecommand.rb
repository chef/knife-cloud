# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'spec_helper'
require 'chef/knife/cloud/server/create_command'

shared_examples_for Chef::Knife::Cloud::ServerCreateCommand do |instance|
  before do
    instance.service = double
    instance.ui.stub(:fatal)
  end

  describe "#before_exec_command" do
    it "calls create_server_dependencies" do
      instance.service.should_receive(:create_server_dependencies)
      instance.before_exec_command
    end
    it "delete_server_dependencies on any error" do
      instance.stub(:execute_command)
      instance.stub(:after_exec_command)
      instance.stub(:validate!)
      instance.stub(:validate_params!)
      instance.service = Chef::Knife::Cloud::Service.new
      instance.stub(:create_service_instance).and_return(instance.service)
      instance.service.stub(:create_server_dependencies).and_raise(Chef::Knife::Cloud::CloudExceptions::ServerCreateDependenciesError)
      instance.service.should_receive(:delete_server_dependencies)
      instance.service.should_not_receive(:delete_server_on_failure)
      instance.should_receive(:exit)
      instance.run
    end
  end

  describe "#execute_command" do
    it "calls create_server" do
      instance.service.should_receive(:create_server).and_return(true)
      instance.execute_command
    end

    it "delete_server_dependencies on any error" do
      instance.stub(:before_exec_command)
      instance.stub(:after_exec_command)
      instance.stub(:validate!)
      instance.stub(:validate_params!)
      instance.service = Chef::Knife::Cloud::Service.new
      instance.stub(:create_service_instance).and_return(instance.service)
      instance.service.stub(:create_server).and_raise(Chef::Knife::Cloud::CloudExceptions::ServerCreateError)
      instance.service.should_receive(:delete_server_dependencies)
      instance.service.should_not_receive(:delete_server_on_failure)
      instance.should_receive(:exit)
      instance.run
    end
  end

  describe "#bootstrap" do
    it "execute with correct method calls" do
      @bootstrap = Object.new
      @bootstrap.stub(:bootstrap)
      Chef::Knife::Cloud::Bootstrapper.stub(:new).and_return(@bootstrap)
      instance.should_receive(:before_bootstrap).ordered
      instance.should_receive(:after_bootstrap).ordered      
      instance.bootstrap
    end
  end

  describe "#get_node_name" do
    it "auto generates chef_node_name" do
      instance.config[:bootstrap_protocol] = 'ssh'
      instance.config[:ssh_password] = 'password'
      instance.config[:image_os_type] = 'linux'
      instance.config[:chef_node_name_prefix] = 'os'
      instance.stub(:set_image_os_type)
      instance.should_receive(:get_node_name).and_call_original
      instance.validate_params!
      instance.config[:chef_node_name].should =~ /os-*/
    end

    it "auto generates unique chef_node_name" do
      node_names = []
      instance.config[:bootstrap_protocol] = 'ssh'
      instance.config[:ssh_password] = 'password'
      instance.config[:image_os_type] = 'linux'
      instance.config[:chef_node_name_prefix] = 'os'
      instance.stub(:set_image_os_type)
      5.times do
        instance.config[:chef_node_name] = nil
        instance.validate_params!
        node_names.should_not include(instance.config[:chef_node_name])
        node_names.push(instance.config[:chef_node_name])
      end
    end    
  end
end
