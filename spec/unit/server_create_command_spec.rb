#
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Copyright:: Copyright (c) Chef Software Inc.
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
      @instance.config[:connection_protocol] = "ssh"
      @instance.config[:ssh_identity_file] = "ssh_identity_file"
      @instance.config[:connection_password] = "connection_password"
      @instance.config[:chef_node_name] = "chef_node_name"
    end

    it "run successfully on all params exist" do
      expect { @instance.validate_params! }.to_not raise_error
    end

    context "when connection_protocol ssh" do
      it "raise error on connection_password and ssh_identity_file are missing" do
        @instance.config.delete(:ssh_identity_file)
        @instance.config.delete(:connection_password)
        expect { @instance.validate_params! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError, " You must provide either SSH Identity file or Connection Password..")
      end
    end

    context "when connection_protocol winrm" do
      it "raise error on connection_password is missing" do
        @instance.config[:connection_protocol] = "winrm"
        @instance.config.delete(:connection_password)
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
      instance.service = Chef::Knife::Cloud::Service.new(config: instance.config)
      allow(instance).to receive(:raise)
      allow(instance.ui).to receive(:fatal)
      instance.config[:delete_server_on_failure] = true
      allow(instance).to receive(:bootstrap).and_raise(Chef::Knife::Cloud::CloudExceptions::BootstrapError)
      expect(instance.service).to receive(:delete_server_dependencies)
      expect(instance.service).to receive(:delete_server_on_failure)
      instance.after_exec_command
    end

    # The RangeError is raised when image_os_type is set to linux and --connection-protocol is set to ssh before windows server bootstrap.
    it "raise error message when bootstrap fails due to image_os_type not exist" do
      instance = Chef::Knife::Cloud::ServerCreateCommand.new
      instance.service = Chef::Knife::Cloud::Service.new(config: instance.config)
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

  describe "--bootstrap-protocol option" do
    it "This flag is deprecated" do
      instance = ServerCreate.new
      description = instance.options[:bootstrap_protocol][:description]
      expect(description).to eq("This flag is deprecated. Use -o/--connection-protocol instead.")
    end
  end
end
