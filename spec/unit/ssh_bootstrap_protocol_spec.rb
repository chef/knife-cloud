#
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
require 'chef/knife/cloud/chefbootstrap/ssh_bootstrap_protocol'
require 'chef/knife/bootstrap_windows_ssh'

describe Chef::Knife::Cloud::SshBootstrapProtocol do
  before do
    @config = {:bootstrap_protocol => 'ssh'}
    @instance = Chef::Knife::Cloud::SshBootstrapProtocol.new(@config)
    allow(@instance).to receive(:sleep).and_return(0)
    allow(@instance).to receive(:print)
  end

  context "Create instance" do
    it "asks for compulsory properties" do
      expect {Chef::Knife::Cloud::SshBootstrapProtocol.new}.to raise_error(ArgumentError)
    end

    it "non windows image" do
      @config[:image_os_type] = 'linux'
      ssh_bootstrap_protocol = Chef::Knife::Cloud::SshBootstrapProtocol.new(@config)
      expect(ssh_bootstrap_protocol.bootstrap.class).to eq(Chef::Knife::Bootstrap)
    end

    it "windows image" do
      @config[:image_os_type] = 'windows'
      ssh_bootstrap_protocol = Chef::Knife::Cloud::SshBootstrapProtocol.new(@config)
      expect(ssh_bootstrap_protocol.bootstrap.class).to eq(Chef::Knife::BootstrapWindowsSsh)
    end
  end

  describe "#wait_for_server_ready" do
    it "execute with correct method calls" do
      allow(@instance).to receive(:tcp_test_ssh).and_return(true)
      expect(@instance).to receive(:tcp_test_ssh).ordered
      @instance.wait_for_server_ready
    end
  end

  describe "#init_bootstrap_options" do
    it "set correct bootstrap config" do
      @config[:bootstrap_ip_address] = "127.0.0.1"
      @config[:chef_node_name] = "testnode"
      @config[:environment] = "_default"
      @config[:ssh_user] = "testuser"
      @config[:ssh_gateway] = "ssh_gateway"
      @config[:forward_agent] = true
      @config[:use_sudo_password] = true
      allow(@config).to receive(:locate_config_value).and_return({})
      @instance.bootstrap = Chef::Knife::Bootstrap.new
      @instance.init_bootstrap_options
      expect(@instance.bootstrap.name_args).to eq([@config[:bootstrap_ip_address]])
      expect(@instance.bootstrap.config[:chef_node_name]).to eq(@config[:chef_node_name])
      expect(@instance.bootstrap.config[:environment]).to eq(@config[:environment])
      expect(@instance.bootstrap.config[:ssh_user]).to eq(@config[:ssh_user])
      expect(@instance.bootstrap.config[:forward_agent]).to be(true)
      expect(@instance.bootstrap.config[:use_sudo_password]).to be(true)
      expect(@instance.bootstrap.config[:ssh_gateway]).to eq(@config[:ssh_gateway])
    end
  end

  describe "#tcp_test_ssh" do

    it "return true" do
      tcpSocket = double()
      allow(tcpSocket).to receive(:close).and_return(true)
      allow(tcpSocket).to receive(:gets).and_return(true)
      allow(TCPSocket).to receive(:new).and_return(tcpSocket)
      allow(IO).to receive(:select).and_return(true)
      allow(tcpSocket.gets).to receive(:nil?).and_return(false)
      allow(tcpSocket.gets).to receive(:empty?).and_return(false)
      expect(@instance.tcp_test_ssh("localhost","22"){}).to be(true)
    end

    it "raise ETIMEDOUT error" do
      allow(TCPSocket).to receive(:new).and_raise(Errno::ETIMEDOUT)
      expect(@instance.tcp_test_ssh("localhost","22"){}).to be(false)
    end

    it "raise EPERM error" do
      allow(TCPSocket).to receive(:new).and_raise(Errno::EPERM)
      expect(@instance.tcp_test_ssh("localhost","22"){}).to be(false)
    end

    it "raise ECONNREFUSED error" do
      allow(TCPSocket).to receive(:new).and_raise(Errno::ECONNREFUSED)
      expect(@instance.tcp_test_ssh("localhost","22"){}).to be(false)
    end

    it "raise EHOSTUNREACH error" do
      allow(TCPSocket).to receive(:new).and_raise(Errno::EHOSTUNREACH)
      expect(@instance.tcp_test_ssh("localhost","22"){}).to be(false)
    end

    it "raise ENETUNREACH error" do
      allow(TCPSocket).to receive(:new).and_raise(Errno::ENETUNREACH)
      expect(@instance.tcp_test_ssh("localhost","22"){}).to be(false)
    end
  end
end
