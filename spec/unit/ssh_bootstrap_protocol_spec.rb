require 'spec_helper'
require 'chef/knife/cloud/chefbootstrap/ssh_bootstrap_protocol'
require 'chef/knife/bootstrap_windows_ssh'

describe Chef::Knife::Cloud::SshBootstrapProtocol do
  before do
    @config = {:bootstrap_protocol => 'ssh'}
    @instance = Chef::Knife::Cloud::SshBootstrapProtocol.new(@config)
    @instance.stub(:sleep).and_return(0)
    @instance.stub(:print)
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
      @instance.stub(:tcp_test_ssh).and_return(true)
      @instance.should_receive(:tcp_test_ssh).ordered
      @instance.wait_for_server_ready
    end
  end

  describe "#init_bootstrap_options" do
    it "set correct bootstrap config" do
      @config[:bootstrap_ip_address] = "127.0.0.1"
      @config[:chef_node_name] = "testnode"
      @config[:environment] = "_default"
      @config[:ssh_user] = "testuser"
      @config.stub(:locate_config_value).and_return({})
      @instance.bootstrap = Chef::Knife::Bootstrap.new
      @instance.init_bootstrap_options
      expect(@instance.bootstrap.name_args).to eq(@config[:bootstrap_ip_address])
      expect(@instance.bootstrap.config[:chef_node_name]).to eq(@config[:chef_node_name])
      expect(@instance.bootstrap.config[:environment]).to eq(@config[:environment])
      expect(@instance.bootstrap.config[:ssh_user]).to eq(@config[:ssh_user])
    end
  end

  describe "#tcp_test_ssh" do
    it "return true" do
      tcpSocket = double()
      tcpSocket.stub(:close).and_return(true)
      tcpSocket.stub(:gets).and_return(true)
      TCPSocket.stub(:new).and_return(tcpSocket)
      IO.stub(:select).and_return(true)
      expect(@instance.tcp_test_ssh("localhost"){}).to be(true)
    end

    it "raise ETIMEDOUT error" do
      TCPSocket.stub(:new).and_raise(Errno::ETIMEDOUT)
      expect(@instance.tcp_test_ssh("localhost"){}).to be(false)
    end

    it "raise EPERM error" do
      TCPSocket.stub(:new).and_raise(Errno::EPERM)
      expect(@instance.tcp_test_ssh("localhost"){}).to be(false)
    end

    it "raise ECONNREFUSED error" do
      TCPSocket.stub(:new).and_raise(Errno::ECONNREFUSED)
      expect(@instance.tcp_test_ssh("localhost"){}).to be(false)
    end

    it "raise EHOSTUNREACH error" do
      TCPSocket.stub(:new).and_raise(Errno::EHOSTUNREACH)
      expect(@instance.tcp_test_ssh("localhost"){}).to be(false)
    end

    it "raise ENETUNREACH error" do
      TCPSocket.stub(:new).and_raise(Errno::ENETUNREACH)
      expect(@instance.tcp_test_ssh("localhost"){}).to be(false)
    end
  end
end
