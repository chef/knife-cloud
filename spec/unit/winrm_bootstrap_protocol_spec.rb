require 'spec_helper'
require 'chef/knife/cloud/chefbootstrap/winrm_bootstrap_protocol'

describe Chef::Knife::Cloud::WinrmBootstrapProtocol do
  before do
    # setup dummy objects.
    @app = App.new
    @app.stub(:is_image_windows?).and_return(true)    
    @instance = Chef::Knife::Cloud::WinrmBootstrapProtocol.new(@app)
    @instance.stub(:sleep).and_return(0)
    @instance.stub(:print)    
  end

  context "Create instance" do
    it "asks for compulsory properties" do
      expect {Chef::Knife::Cloud::WinrmBootstrapProtocol.new}.to raise_error(ArgumentError)
    end

    it "windows image" do
      @app.stub(:is_image_windows?).and_return(true)
      winrm_bootstrap_protocol = Chef::Knife::Cloud::WinrmBootstrapProtocol.new(@app)
      expect(winrm_bootstrap_protocol.bootstrap.class).to eq(Chef::Knife::BootstrapWindowsWinrm)
    end

    it "non windows image" do
      @app.stub(:is_image_windows?).and_return(false)
      expect{Chef::Knife::Cloud::WinrmBootstrapProtocol.new(@app)}.to raise_error(RuntimeError)
    end
  end
  
  describe "#wait_for_server_ready" do
    it "execute with correct method calls" do
      @instance.stub(:tcp_test_winrm).and_return(true)
      @app.stub(:locate_config_value).and_return(true)
      @instance.should_receive(:tcp_test_winrm).ordered
      @instance.wait_for_server_ready
    end
  end

  describe "#init_bootstrap_options" do
    it "set correct bootstrap config" do
      @app.config[:bootstrap_ip_address] = "127.0.0.1"
      @app.config[:chef_node_name] = "testnode"
      @app.config[:environment] = "_default"
      @app.config[:winrm_user] = "testuser"
      @app.stub(:locate_config_value).and_return("testuser")
      @instance.bootstrap = Chef::Knife::Bootstrap.new
      @instance.init_bootstrap_options
      expect(@instance.bootstrap.name_args).to eq(@app.config[:bootstrap_ip_address])
      expect(@instance.bootstrap.config[:chef_node_name]).to eq(@app.config[:chef_node_name])
      expect(@instance.bootstrap.config[:environment]).to eq(@app.config[:environment])
      expect(@instance.bootstrap.config[:winrm_user]).to eq(@app.config[:winrm_user])
    end
  end

  describe "#tcp_test_winrm" do
    it "return true" do
      TCPSocket.stub(:new){true}
      expect(@instance.tcp_test_winrm("localhost","5989")).to be(true)
    end

    it "raise SocketError error" do
      TCPSocket.stub(:new).and_raise(SocketError)
      expect(@instance.tcp_test_winrm("localhost","5989")).to be(false)
    end

    it "raise ETIMEDOUT error" do
      TCPSocket.stub(:new).and_raise(Errno::ETIMEDOUT)
      expect(@instance.tcp_test_winrm("localhost","5989")).to be(false)
    end

    it "raise EPERM error" do
      TCPSocket.stub(:new).and_raise(Errno::EPERM)
      expect(@instance.tcp_test_winrm("localhost","5989"){raise Errno::EPERM}).to be(false)
    end

    it "raise ECONNREFUSED error" do
      TCPSocket.stub(:new).and_raise(Errno::ECONNREFUSED)
      expect(@instance.tcp_test_winrm("localhost","5989"){raise Errno::ECONNREFUSED}).to be(false)
    end

    it "raise EHOSTUNREACH error" do
      TCPSocket.stub(:new).and_raise(Errno::EHOSTUNREACH)
      expect(@instance.tcp_test_winrm("localhost","5989"){raise Errno::EHOSTUNREACH}).to be(false)
    end

    it "raise ENETUNREACH error" do
      TCPSocket.stub(:new).and_raise(Errno::ENETUNREACH)
      expect(@instance.tcp_test_winrm("localhost","5989"){raise Errno::ENETUNREACH}).to be(false)
    end
  end
end
