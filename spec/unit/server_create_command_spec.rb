#
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Copyright:: Copyright (c) 2013-2014 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "support/shared_examples_for_command_bootstrap"
require "support/shared_examples_for_servercreatecommand"
require "net/ssh"
require "chef/knife/cloud/server/create_options"

describe Chef::Knife::Cloud::ServerCreateCommand do
  it_behaves_like Chef::Knife::Cloud::BootstrapCommand, Chef::Knife::Cloud::ServerCreateCommand.new
  it_behaves_like Chef::Knife::Cloud::ServerCreateCommand, Chef::Knife::Cloud::ServerCreateCommand.new

  describe "#validate_params!" do
    before(:each) do
      @instance = Chef::Knife::Cloud::ServerCreateCommand.new
      allow(@instance.ui).to receive(:error)
      Chef::Config[:knife][:connection_protocol] = "ssh"
      Chef::Config[:knife][:ssh_identity_file] = "ssh_identity_file"
      Chef::Config[:knife][:connection_password] = "connection_password"
      Chef::Config[:knife][:chef_node_name] = "chef_node_name"
    end
    after(:all) do
      Chef::Config[:knife].delete(:connection_protocol)
      Chef::Config[:knife].delete(:ssh_identity_file)
      Chef::Config[:knife].delete(:chef_node_name)
      Chef::Config[:knife].delete(:connection_password)
    end

    it "run sucessfully on all params exist" do
      expect { @instance.validate_params! }.to_not raise_error
      expect(@instance.config[:chef_node_name]).to eq(Chef::Config[:knife][:chef_node_name])
    end

    context "when connection_protocol ssh" do
      it "raise error on connection_password and ssh_identity_file are missing" do
        Chef::Config[:knife].delete(:ssh_identity_file)
        Chef::Config[:knife].delete(:connection_password)
        expect { @instance.validate_params! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError, " You must provide either SSH Identity file or Connection Password..")
      end
    end

    context "when connection_protocol winrm" do
      it "raise error on connection_password is missing" do
        Chef::Config[:knife][:connection_protocol] = "winrm"
        Chef::Config[:knife].delete(:connection_password)
        expect { @instance.validate_params! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError, " You must provide Connection Password..")
      end
    end
  end

  describe "#after_exec_command" do
    it "calls bootstrap" do
      instance = Chef::Knife::Cloud::ServerCreateCommand.new
      expect(instance).to receive(:bootstrap)
      instance.after_exec_command
    end

    it "delete server on bootstrap failure" do
      instance = Chef::Knife::Cloud::ServerCreateCommand.new
      instance.service = Chef::Knife::Cloud::Service.new
      allow(instance).to receive(:raise)
      allow(instance.ui).to receive(:fatal)
      instance.config[:delete_server_on_failure] = true
      allow(instance).to receive(:bootstrap).and_raise(Chef::Knife::Cloud::CloudExceptions::BootstrapError)
      expect(instance.service).to receive(:delete_server_dependencies)
      expect(instance.service).to receive(:delete_server_on_failure)
      instance.after_exec_command
    end

    # Currently the RangeError is occured when image_os_type is set to linux and --connection-protocol is set to ssh before windows server bootstrap.
    it "raise error message when bootstrap fails due to image_os_type not exist" do
      instance = Chef::Knife::Cloud::ServerCreateCommand.new
      instance.service = Chef::Knife::Cloud::Service.new
      allow(instance.ui).to receive(:fatal)
      instance.config[:delete_server_on_failure] = true
      allow(instance).to receive(:bootstrap).and_raise(RangeError)
      expect(instance.service).to receive(:delete_server_dependencies)
      expect(instance.service).to receive(:delete_server_on_failure)
      expect { instance.after_exec_command }.to raise_error(RangeError, "Check if --connection-protocol and --image-os-type is correct. RangeError")
    end
  end

  describe "#set_default_config" do
    it "set valid image os type" do
      instance = Chef::Knife::Cloud::ServerCreateCommand.new
      instance.config[:connection_protocol] = "winrm"
      instance.set_default_config
      expect(instance.config[:image_os_type]).to eq("windows")
    end
  end

  class ServerCreate < Chef::Knife::Cloud::ServerCreateCommand
    include Chef::Knife::Cloud::ServerCreateOptions
  end

  describe "Bootstrap Protocol option" do
    it "not to be set in chef config knife options" do
      instance = ServerCreate.new
      bootstrap_protocol = "bootstrap_protocol"

      instance.options[:bootstrap_protocol][:proc].call bootstrap_protocol
      expect(Chef::Config[:knife][:bootstrap_protocol]).to eq(nil)
    end
  end
end
