# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'support/shared_examples_for_command'
require 'support/shared_examples_for_servercreatecommand'
require 'net/ssh'

describe Chef::Knife::Cloud::ServerCreateCommand do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::ServerCreateCommand.new
  it_behaves_like Chef::Knife::Cloud::ServerCreateCommand, Chef::Knife::Cloud::ServerCreateCommand.new

  describe "#after_exec_command" do
    it "calls bootstrap" do
      instance = Chef::Knife::Cloud::ServerCreateCommand.new
      instance.should_receive(:bootstrap)
      instance.after_exec_command
    end

    it "delete server on bootstrap failure" do
      instance = Chef::Knife::Cloud::ServerCreateCommand.new
      instance.service = Chef::Knife::Cloud::Service.new
      instance.ui.stub(:fatal)
      instance.config[:delete_server_on_failure] = true
      instance.stub(:bootstrap).and_raise(Chef::Knife::Cloud::CloudExceptions::BootstrapError)
      instance.service.should_receive(:delete_server_dependencies)
      instance.service.should_receive(:delete_server_on_failure)
      instance.after_exec_command
    end
 end
end
