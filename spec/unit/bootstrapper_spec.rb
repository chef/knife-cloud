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

      it "instantiates Unix Distribution class." do
        Chef::Knife::Cloud::UnixDistribution.stub_chain(:new, :template)
        @instance.create_bootstrap_protocol
      end

      it "doesn't instantiate Windows Distribution class." do
        Chef::Knife::Cloud::WindowsDistribution.should_not_receive(:new)
        @instance.create_bootstrap_protocol
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

      it "instantiates Windows Distribution class." do
        Chef::Knife::Cloud::WindowsDistribution.stub_chain(:new, :template)
        @instance.create_bootstrap_protocol
      end

      it "gets the correct template file from the Windows Distribution." do
        @instance.create_bootstrap_protocol
        @config[:template_file].should match "windows-chef-client-msi.erb"
      end

      it "doesn't instantiate Unix Distribution class." do
        Chef::Knife::Cloud::UnixDistribution.should_not_receive(:new)
        @instance.create_bootstrap_protocol
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

    context "when bootstrap_protocol set to nil." do
      before do
        @config[:bootstrap_protocol] = nil
      end

      it "instantiates Unix Distribution class." do
        Chef::Knife::Cloud::UnixDistribution.stub_chain(:new, :template)
        @instance.create_bootstrap_protocol
      end
    end
  end
end
