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

require 'spec_helper'
require 'chef/knife/cloud/chefbootstrap/bootstrapper'
require 'chef/knife/bootstrap_windows_ssh'

describe Chef::Knife::Cloud::Bootstrapper do
  before(:each) do
    @config = {:bootstrap_protocol => 'ssh'}
    @instance = Chef::Knife::Cloud::Bootstrapper.new(@config)
  end

  context "Bootstrapper initializer" do
    it "asks for compulsory properties while creating instance" do
      expect {Chef::Knife::Cloud::Bootstrapper.new}.to raise_error(ArgumentError)
    end

    it "creating instance" do
      expect {Chef::Knife::Cloud::Bootstrapper.new(@config)}.to_not raise_error
      expect(Chef::Knife::Cloud::Bootstrapper.new(@config).class).to eq(Chef::Knife::Cloud::Bootstrapper)
    end
  end

  describe "#bootstrap Linux machine with ssh" do
    it "executes with correct method calls" do
      @ssh_bootstrap_protocol = Chef::Knife::Cloud::SshBootstrapProtocol.new(@config)
      allow(@instance).to receive(:create_bootstrap_protocol).and_return(@ssh_bootstrap_protocol)
      @unix_distribution = Chef::Knife::Cloud::UnixDistribution.new(@config)
      expect(@instance).to receive(:create_bootstrap_protocol).ordered
      allow(@instance).to receive(:create_bootstrap_distribution).and_return(@unix_distribution)
      expect(@ssh_bootstrap_protocol).to receive(:send_bootstrap_command).ordered
      @instance.bootstrap
    end
  end

  describe "#bootstrap Windows machine with winrm" do
    it "executes with correct method calls" do
      @winrm_bootstrap_protocol = Chef::Knife::Cloud::WinrmBootstrapProtocol.new(@config)
      allow(@instance).to receive(:create_bootstrap_protocol).and_return(@winrm_bootstrap_protocol)
      @windows_distribution = Chef::Knife::Cloud::WindowsDistribution.new(@config)
      expect(@instance).to receive(:create_bootstrap_protocol).ordered
      allow(@instance).to receive(:create_bootstrap_distribution).and_return(@windows_distribution)
      expect(@winrm_bootstrap_protocol).to receive(:send_bootstrap_command).ordered
      @instance.bootstrap
    end
  end

  describe "#create_bootstrap_distribution" do
      context "when image_os_type set to windows" do
        before(:each) do
          @config[:image_os_type] = "windows"
        end

        it "instantiates Windows Distribution class." do
          expect(Chef::Knife::Cloud::WindowsDistribution).to receive(:new).with(@config)
          @instance.create_bootstrap_distribution
        end

        it "doesn't instantiate Unix Distribution class." do
          expect(Chef::Knife::Cloud::UnixDistribution).to_not receive(:new)
          @instance.create_bootstrap_distribution
        end

      end

      context "when image_os_type set to linux" do
        before(:each) do
          @config[:image_os_type] = "linux"
        end

        it "instantiates Unix Distribution class." do
          expect(Chef::Knife::Cloud::UnixDistribution).to receive(:new).with(@config)
          @instance.create_bootstrap_distribution
        end

        it "doesn't instantiate Windows Distribution class." do
          expect(Chef::Knife::Cloud::WindowsDistribution).to_not receive(:new)
          @instance.create_bootstrap_distribution
        end
      end

      context "when image_os_type set to invalid" do
        before(:each) do
          @config[:image_os_type] = "invalid"
        end

        it "raise bootstrap error" do
          ui = double()
          expect(@instance).to receive(:ui).and_return(ui)
          allow(ui).to receive(:fatal)
          expect { @instance.create_bootstrap_distribution }.to raise_error(Chef::Knife::Cloud::CloudExceptions::BootstrapError, "Invalid bootstrap distribution. image_os_type should be either windows or linux.")
        end
      end      
    end


  describe "#create_bootstrap_protocol" do
    context "when bootstrap_protocol set to ssh" do
      before(:each) do
        @config[:bootstrap_protocol] = "ssh"
      end

      it "instantiates SshBootstrapProtocol class." do
        expect(Chef::Knife::Cloud::SshBootstrapProtocol).to receive(:new)
        @instance.create_bootstrap_protocol
      end

      it "doesn't instantiate Windows Distribution class." do
        expect(Chef::Knife::Cloud::WinrmBootstrapProtocol).to_not receive(:new)
        @instance.create_bootstrap_protocol
      end

    end

    context "when bootstrap_protocol set to winrm" do
      before(:each) do
        @config[:bootstrap_protocol] = "winrm"
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

    context "when bootstrap_protocol set to nil." do
      before do
        @config[:bootstrap_protocol] = nil
      end

      it "instantiates SshBootstrapProtocol class." do
        expect(Chef::Knife::Cloud::SshBootstrapProtocol).to receive(:new)
        @instance.create_bootstrap_protocol
      end
    end

    context "when bootstrap_protocol set to invalid." do
      before do
        @config[:bootstrap_protocol] = "invalid"
      end

      it "instantiates SshBootstrapProtocol class." do
        ui = double()
        expect(@instance).to receive(:ui).and_return(ui)
        allow(ui).to receive(:fatal)
        expect { @instance.create_bootstrap_protocol }.to raise_error(Chef::Knife::Cloud::CloudExceptions::BootstrapError, "Invalid bootstrap protocol.")
      end
    end    
  end
end
