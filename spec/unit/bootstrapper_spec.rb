require 'spec_helper'
require 'chef/knife/cloud/chefbootstrap/bootstrapper'
require 'chef/knife/bootstrap_windows_ssh'

describe Chef::Knife::Cloud::Bootstrapper do
  before do
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

  describe "#bootstrap" do
    it "execute with correct method calls" do
      @config.stub(:is_image_windows?).and_return(false)
      @ssh_bootstrap_protocol = Chef::Knife::Cloud::SshBootstrapProtocol.new(@config)
      @instance.stub(:create_bootstrap_protocol).and_return(@ssh_bootstrap_protocol)
      @ssh_bootstrap_protocol.stub(:send_bootstrap_command).and_return(true)
      @instance.should_receive(:create_bootstrap_protocol).ordered
      #@instance.should_receive(:create_bootstrap_distribution).ordered
      @ssh_bootstrap_protocol.should_receive(:send_bootstrap_command).ordered
      @instance.bootstrap
    end
  end

  describe "#create_bootstrap_protocol" do
    context "when bootstrap_protocol set to ssh" do
      before do
        @config[:bootstrap_protocol] = "ssh"
      end

      it "create SshBootstrapProtocol for linux image" do
        expect(@instance.create_bootstrap_protocol).to be_an_instance_of(Chef::Knife::Cloud::SshBootstrapProtocol)
      end
    end

    context "when bootstrap_protocol set to winrm" do
      before do
        @config[:bootstrap_protocol] = "winrm"
        @config[:image_os_type] = "windows"
      end

      it "create bootstrap_protocol for windows image" do
        expect(@instance.create_bootstrap_protocol).to be_an_instance_of(Chef::Knife::Cloud::WinrmBootstrapProtocol)
      end
    end

    context "when bootstrap_protocol set to invalid" do
      before do
        @config[:bootstrap_protocol] = "invalid"
      end

      it "raise an exception, invalid bootstrap protocol" do
        @instance.ui.should_receive(:fatal)
        expect{@instance.create_bootstrap_protocol}.to raise_error(RuntimeError)
      end
    end
  end
end
