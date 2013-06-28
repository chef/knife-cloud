# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'chef/knife/cloud/fog/server_create_command'

describe Chef::Knife::Cloud::FogServerCreateCommand do
  before do
    @app = App.new
    @service = Object.new
    @instance = Chef::Knife::Cloud::FogServerCreateCommand.new(@app, @service)
    @instance.stub(:print)
    @instance.stub(:puts)

  end

  it "asks for compulsory properties while creating instance" do
    expect {Chef::Knife::Cloud::FogServerCreateCommand.new}.to raise_error(ArgumentError)
  end

  it "successfully creates a server instance." do
    @server = mock()
    @service.stub_chain(:connection, :servers, :create).and_return(@server)
    @instance.stub(:create_server_def)
    @server.stub(:name)
    @server.stub(:id)
    @instance.stub!(:msg_pair)
    @server.stub(:wait_for)
    @app.stub(:locate_config_value).and_return(600) #returning the default server_create_timeout value
    @instance.create
  end

  it "runs with correct sequence of method calls" do
    @instance.should_receive(:validate!).ordered
    @instance.should_receive(:before_handler).ordered
    @instance.should_receive(:exec_command).ordered
    @instance.should_receive(:after_handler).ordered
    @instance.run
  end

  it { expect {@instance.create.to raise_error(NameError, "Chef::Knife::Cloud::FogServerCreateCommand::Excon")}}

  it { expect { @instance.create_server_def }.to raise_error(Chef::Exceptions::Override, "You must override create_server_def in #{@instance.to_s} to form server creation arguments.")}

  it "calls delete_server_dependencies when failure in creating server" do
    @instance.should_receive(:create_server_dependencies).ordered
    @instance.should_receive(:create).ordered.and_raise(Chef::Knife::Cloud::CloudExceptions::ServerCreateError)
    @instance.should_receive(:delete_server_dependencies).ordered
    @instance.ui.should_receive(:fatal)
    expect {@instance.run}.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServerCreateError)
  end

  it "doesn't call delete_server_dependencies when succeeds in creating server" do
    @instance.should_receive(:create_server_dependencies).ordered
    @instance.stub(:create)
    @instance.should_not_receive(:delete_server_dependencies)
    @instance.run
  end

end
