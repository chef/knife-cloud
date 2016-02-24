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
require 'chef/knife/cloud/chefbootstrap/winrm_bootstrap_protocol'

describe Chef::Knife::Cloud::WinrmBootstrapProtocol do
  before do
    @config = {:bootstrap_protocol => 'winrm'}
    @config = {:image_os_type => 'windows'}
    @instance = Chef::Knife::Cloud::WinrmBootstrapProtocol.new(@config)
    allow(@instance).to receive(:sleep).and_return(0)
    allow(@instance).to receive(:print)
  end

  context "Create instance" do
    it "asks for compulsory properties" do
      expect {Chef::Knife::Cloud::WinrmBootstrapProtocol.new}.to raise_error(ArgumentError)
    end

    it "windows image" do
      @config[:image_os_type] = 'windows'
      winrm_bootstrap_protocol = Chef::Knife::Cloud::WinrmBootstrapProtocol.new(@config)
      expect(winrm_bootstrap_protocol.bootstrap.class).to eq(Chef::Knife::BootstrapWindowsWinrm)
    end
  end

  describe "#wait_for_server_ready" do
    it "execute with correct method calls" do
      @config[:image_os_type] = 'windows'
      allow(@instance).to receive(:tcp_test_winrm).and_return(true)
      expect(@instance).to receive(:tcp_test_winrm).ordered
      @instance.wait_for_server_ready
    end
  end

  describe "#init_bootstrap_options" do
    it "set correct bootstrap config" do
      @config[:bootstrap_ip_address] = "127.0.0.1"
      @config[:chef_node_name] = "testnode"
      @config[:environment] = "_default"
      @config[:winrm_user] = "testuser"
      @config[:auth_timeout] = "100"
      @config[:winrm_ssl_verify_mode] = "verify_none"
      @instance.bootstrap = Chef::Knife::Bootstrap.new
      @instance.init_bootstrap_options
      expect(@instance.bootstrap.name_args).to eq([@config[:bootstrap_ip_address]])
      expect(@instance.bootstrap.config[:chef_node_name]).to eq(@config[:chef_node_name])
      expect(@instance.bootstrap.config[:environment]).to eq(@config[:environment])
      expect(@instance.bootstrap.config[:winrm_user]).to eq(@config[:winrm_user])
      expect(@instance.bootstrap.config[:auth_timeout]).to eq(@config[:auth_timeout])
      expect(@instance.bootstrap.config[:winrm_ssl_verify_mode]).to eq(@config[:winrm_ssl_verify_mode])
    end
  end

  describe "#tcp_test_winrm" do
    it "return true" do
      tcpSocket = double()
      allow(tcpSocket).to receive(:close).and_return(true)
      allow(TCPSocket).to receive(:new).and_return(tcpSocket)
      expect(@instance.tcp_test_winrm("localhost","5989")).to be(true)
    end

    it "raise SocketError error" do
      allow(TCPSocket).to receive(:new).and_raise(SocketError)
      expect(@instance.tcp_test_winrm("localhost","5989")).to be(false)
    end

    it "raise ETIMEDOUT error" do
      allow(TCPSocket).to receive(:new).and_raise(Errno::ETIMEDOUT)
      expect(@instance.tcp_test_winrm("localhost","5989")).to be(false)
    end

    it "raise EPERM error" do
      allow(TCPSocket).to receive(:new).and_raise(Errno::EPERM)
      expect(@instance.tcp_test_winrm("localhost","5989"){raise Errno::EPERM}).to be(false)
    end

    it "raise ECONNREFUSED error" do
      allow(TCPSocket).to receive(:new).and_raise(Errno::ECONNREFUSED)
      expect(@instance.tcp_test_winrm("localhost","5989"){raise Errno::ECONNREFUSED}).to be(false)
    end

    it "raise EHOSTUNREACH error" do
      allow(TCPSocket).to receive(:new).and_raise(Errno::EHOSTUNREACH)
      expect(@instance.tcp_test_winrm("localhost","5989"){raise Errno::EHOSTUNREACH}).to be(false)
    end

    it "raise ENETUNREACH error" do
      allow(TCPSocket).to receive(:new).and_raise(Errno::ENETUNREACH)
      expect(@instance.tcp_test_winrm("localhost","5989"){raise Errno::ENETUNREACH}).to be(false)
    end
  end
end
