# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'chef/knife/cloud/server/create_command'

describe Chef::Knife::Cloud::ServerCreateCommand do
  let (:instance) { Chef::Knife::Cloud::ServerCreateCommand.new(App.new, Object.new) }

  it { expect {Chef::Knife::Cloud::ServerCreateCommand.new}.to raise_error(ArgumentError, "wrong number of arguments (0 for 2)") }

  it "runs with correct method calls" do
    instance.stub(:create_server_dependencies)
    instance.stub(:create)
    instance.stub(:bootstrap)
    instance.should_receive(:validate!).ordered
    instance.should_receive(:before_handler).ordered
    instance.should_receive(:create_server_dependencies).ordered
    instance.should_receive(:create).ordered
    instance.should_receive(:bootstrap).ordered
    instance.should_receive(:after_handler).ordered
    #instance.should_receive(:custom_arguments).ordered
    instance.run
  end

  it "calls delete_server_dependencies when failure in creating server" do
    instance.stub(:create_server_dependencies)
    instance.stub(:create).and_raise(Chef::Knife::Cloud::CloudExceptions::ServerCreateError)

    instance.should_receive(:delete_server_dependencies)
    instance.ui.should_receive(:fatal)
    expect {instance.run}.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServerCreateError)
  end

  it "calls delete_server_dependencies when failure in creating server dependencies" do
    instance.stub(:create_server_dependencies).and_raise(Chef::Knife::Cloud::CloudExceptions::ServerCreateDependenciesError)
    instance.stub(:create)

    instance.should_receive(:delete_server_dependencies)
    instance.ui.should_receive(:fatal)
    expect {instance.run}.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServerCreateDependenciesError)
  end

  it {expect {instance.run}.to raise_error(Chef::Exceptions::Override, "You must override create_server_dependencies in #{instance.to_s} to create dependencies required for server creation.")}

  it "raises exception to override create server method" do
    instance.stub(:create_server_dependencies)
    expect {instance.run}.to raise_error(Chef::Exceptions::Override, "You must override create in #{instance.to_s} for server creation.")
  end

  it {expect {instance.delete_server_dependencies}.to raise_error(Chef::Exceptions::Override, "You must override delete_server_dependencies in #{instance.to_s} to remove dependencies created before server creation.")}

 end
