#
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
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

require "spec_helper"
require "chef/knife/cloud/chefbootstrap/bootstrapper"

describe Chef::Knife::Cloud::Bootstrapper do
  before(:each) do
    @config = { connection_protocol: "ssh" }
    @instance = Chef::Knife::Cloud::Bootstrapper.new(@config)
  end

  context "Bootstrapper initializer" do
    it "asks for compulsory properties while creating instance" do
      expect { Chef::Knife::Cloud::Bootstrapper.new }.to raise_error(ArgumentError)
    end

    it "creating instance" do
      expect { Chef::Knife::Cloud::Bootstrapper.new(@config) }.to_not raise_error
      expect(Chef::Knife::Cloud::Bootstrapper.new(@config).class).to eq(Chef::Knife::Cloud::Bootstrapper)
    end
  end

  describe "#bootstrap machine" do
    let(:bootstrap_distribution) { Chef::Knife::Cloud::BootstrapDistribution.new(@config) }

    it "executes with correct method calls with ssh" do
      ssh_bootstrap_protocol = Chef::Knife::Cloud::SshBootstrapProtocol.new(@config)
      allow(@instance).to receive(:create_bootstrap_protocol).and_return(ssh_bootstrap_protocol)
      expect(@instance).to receive(:create_bootstrap_protocol).ordered
      allow(@instance).to receive(:create_bootstrap_distribution).and_return(bootstrap_distribution)
      expect(ssh_bootstrap_protocol).to receive(:send_bootstrap_command).ordered
      @instance.bootstrap
    end

    it "executes with correct method calls with winrm" do
      winrm_bootstrap_protocol = Chef::Knife::Cloud::WinrmBootstrapProtocol.new(@config)
      allow(@instance).to receive(:create_bootstrap_protocol).and_return(winrm_bootstrap_protocol)
      expect(@instance).to receive(:create_bootstrap_protocol).ordered
      allow(@instance).to receive(:create_bootstrap_distribution).and_return(bootstrap_distribution)
      expect(winrm_bootstrap_protocol).to receive(:send_bootstrap_command).ordered
      @instance.bootstrap
    end
  end

  describe "#create_bootstrap_distribution" do
    context "when image_os_type set to windows" do
      before(:each) do
        @config[:image_os_type] = "windows"
      end

      it "instantiates the BootstrapDistribution class" do
        expect(Chef::Knife::Cloud::BootstrapDistribution).to receive(:new).with(@config)
        @instance.create_bootstrap_distribution
      end

    end

    context "when image_os_type set to linux" do
      before(:each) do
        @config[:image_os_type] = "linux"
      end

      it "instantiates the BootstrapDistribution class" do
        expect(Chef::Knife::Cloud::BootstrapDistribution).to receive(:new).with(@config)
        @instance.create_bootstrap_distribution
      end

    end

    context "when image_os_type set to invalid" do
      before(:each) do
        @config[:image_os_type] = "invalid"
      end

      it "raise bootstrap error" do
        ui = double
        expect(@instance).to receive(:ui).and_return(ui)
        allow(ui).to receive(:fatal)
        expect { @instance.create_bootstrap_distribution }.to raise_error(Chef::Knife::Cloud::CloudExceptions::BootstrapError, "Invalid bootstrap distribution. image_os_type should be either windows or linux.")
      end
    end
  end

  describe "#create_bootstrap_protocol" do
    context "when connection_protocol set to ssh" do
      before(:each) do
        @config[:connection_protocol] = "ssh"
      end

      it "instantiates SshBootstrapProtocol class." do
        expect(Chef::Knife::Cloud::SshBootstrapProtocol).to receive(:new)
        @instance.create_bootstrap_protocol
      end

      it "doesn't instantiate WinrmBootstrapProtocol class." do
        expect(Chef::Knife::Cloud::WinrmBootstrapProtocol).to_not receive(:new)
        @instance.create_bootstrap_protocol
      end

    end

    context "when connection_protocol set to winrm" do
      before(:each) do
        @config[:connection_protocol] = "winrm"
      end

      it "instantiates WinrmBootstrapProtocol class." do
        expect(Chef::Knife::Cloud::WinrmBootstrapProtocol).to receive(:new)
        @instance.create_bootstrap_protocol
      end

      it "doesn't instantiate SshBootstrapProtocol class." do
        expect(Chef::Knife::Cloud::SshBootstrapProtocol).to_not receive(:new)
        @instance.create_bootstrap_protocol
      end
    end

    context "when connection_protocol set to nil" do
      before do
        @config[:connection_protocol] = nil
      end

      it "instantiates SshBootstrapProtocol class." do
        expect(Chef::Knife::Cloud::SshBootstrapProtocol).to receive(:new)
        @instance.create_bootstrap_protocol
      end
    end

    context "when connection_protocol set to invalid." do
      before do
        @config[:connection_protocol] = "invalid"
      end

      it "instantiates SshBootstrapProtocol class." do
        ui = double
        expect(@instance).to receive(:ui).and_return(ui)
        allow(ui).to receive(:fatal)
        expect { @instance.create_bootstrap_protocol }.to raise_error(Chef::Knife::Cloud::CloudExceptions::BootstrapError, "Invalid bootstrap protocol.")
      end
    end
  end
end
