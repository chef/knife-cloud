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
      instance.stub(:raise)
      instance.ui.stub(:fatal)
      instance.config[:delete_server_on_failure] = true
      instance.stub(:bootstrap).and_raise(Chef::Knife::Cloud::CloudExceptions::BootstrapError)
      instance.service.should_receive(:delete_server_dependencies)
      instance.service.should_receive(:delete_server_on_failure)
      instance.after_exec_command
    end

    # Currently the RangeError is occured when image_os_type is set to linux and bootstrap-protocol is set to ssh before windows server bootstrap.
    it "raise error message when bootstrap fails due to image_os_type not exist" do
      instance = Chef::Knife::Cloud::ServerCreateCommand.new
      instance.service = Chef::Knife::Cloud::Service.new
      instance.ui.stub(:fatal)
      instance.config[:delete_server_on_failure] = true
      instance.stub(:bootstrap).and_raise(RangeError)
      instance.service.should_receive(:delete_server_dependencies)
      instance.service.should_receive(:delete_server_on_failure)
      expect { instance.after_exec_command }.to raise_error(RangeError, "Check if --bootstrap-protocol and --image-os-type is correct. RangeError")
    end
  end

  describe "#set_image_os_type" do
    it "set valid image os type" do
      instance = Chef::Knife::Cloud::ServerCreateCommand.new
      instance.config[:bootstrap_protocol] = 'winrm'
      instance.set_image_os_type
      expect(instance.config[:image_os_type]).to eq('windows')
    end
  end

  describe "#validate_params!" do
    it "calls set_image_os_type" do
      instance = Chef::Knife::Cloud::ServerCreateCommand.new
      instance.stub(:locate_config_value).and_return(false)
      instance.stub(:raise)
      instance.ui.stub(:error)
      instance.should_receive(:set_image_os_type)
      instance.validate_params!
    end
  end  
end
