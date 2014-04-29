# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'support/shared_examples_for_command'
require 'support/shared_examples_for_servercreatecommand'
require 'net/ssh'

describe Chef::Knife::Cloud::ServerCreateCommand do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::ServerCreateCommand.new
  it_behaves_like Chef::Knife::Cloud::ServerCreateCommand, Chef::Knife::Cloud::ServerCreateCommand.new

  describe "#validate_params!" do
    before(:each) do
      @instance = Chef::Knife::Cloud::ServerCreateCommand.new
      @instance.ui.stub(:error)
      Chef::Config[:knife][:bootstrap_protocol] = "ssh"
      Chef::Config[:knife][:identity_file] = "identity_file"
      Chef::Config[:knife][:ssh_password] = "ssh_password"
      Chef::Config[:knife][:chef_node_name] = "chef_node_name"
      Chef::Config[:knife][:winrm_password] = "winrm_password"
    end
    after(:all) do
      Chef::Config[:knife].delete(:bootstrap_protocol)
      Chef::Config[:knife].delete(:identity_file)
      Chef::Config[:knife].delete(:chef_node_name)
      Chef::Config[:knife].delete(:ssh_password)
      Chef::Config[:knife].delete(:winrm_password)
    end

    it "run sucessfully on all params exist" do
      expect { @instance.validate_params! }.to_not raise_error
      expect(@instance.config[:chef_node_name]).to eq(Chef::Config[:knife][:chef_node_name])
    end

    context "when bootstrap_protocol ssh" do
      it "raise error on ssh_password and identity_file are missing" do
        Chef::Config[:knife].delete(:identity_file)
        Chef::Config[:knife].delete(:ssh_password)
        expect { @instance.validate_params! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError, " You must provide either Identity file or SSH Password..")
      end
    end

    context "when bootstrap_protocol winrm" do
      it "raise error on winrm_password is missing" do
        Chef::Config[:knife][:bootstrap_protocol] = "winrm"
        Chef::Config[:knife].delete(:winrm_password)
        expect { @instance.validate_params! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError, " You must provide Winrm Password..")
      end
    end
  end

  describe "#after_exec_command" do
    it "calls bootstrap" do
      instance = Chef::Knife::Cloud::ServerCreateCommand.new
      instance.should_receive(:bootstrap)
      instance.after_exec_command
    end

    it "delete server on bootstrap failure" do
      instance = Chef::Knife::Cloud::ServerCreateCommand.new
      instance.service = Chef::Knife::Cloud::Service.new
      instance.stub(:raise)
      instance.ui.stub(:fatal)
      instance.config[:delete_server_on_failure] = true
      instance.stub(:bootstrap).and_raise(Chef::Knife::Cloud::CloudExceptions::BootstrapError)
      instance.service.should_receive(:delete_server_dependencies)
      instance.service.should_receive(:delete_server_on_failure)
      instance.after_exec_command
    end

    # Currently the RangeError is occured when image_os_type is set to linux and bootstrap-protocol is set to ssh before windows server bootstrap.
    it "raise error message when bootstrap fails due to image_os_type not exist" do
      instance = Chef::Knife::Cloud::ServerCreateCommand.new
      instance.service = Chef::Knife::Cloud::Service.new
      instance.ui.stub(:fatal)
      instance.config[:delete_server_on_failure] = true
      instance.stub(:bootstrap).and_raise(RangeError)
      instance.service.should_receive(:delete_server_dependencies)
      instance.service.should_receive(:delete_server_on_failure)
      expect { instance.after_exec_command }.to raise_error(RangeError, "Check if --bootstrap-protocol and --image-os-type is correct. RangeError")
    end
  end

  describe "#set_default_config" do
    it "set valid image os type" do
      instance = Chef::Knife::Cloud::ServerCreateCommand.new
      instance.config[:bootstrap_protocol] = 'winrm'
      instance.set_default_config
      expect(instance.config[:image_os_type]).to eq('windows')
    end
  end

  describe "#create_user_data" do
    context "bootstrap protocol winrm" do
      before(:all) do
        @instance = Chef::Knife::Cloud::ServerCreateCommand.new
        @instance.config[:bootstrap_protocol] = "winrm"
        @instance.config[:winrm_user] = "testuser_winrm"
        @instance.config[:winrm_password] = "testpassword_winrm"
      end

      it "user data includes user create script for testuser_winrm" do
        server_def = @instance.create_user_data
        server_def.should include("testuser_winrm")
        server_def.should include("$newuser.SetPassword(\"testpassword_winrm\")")
      end

      it "user data includes winrm config script" do
        server_def = @instance.create_user_data
        server_def.should include("testuser_winrm")
        server_def.should include("winrm quickconfig -q")
        server_def.should include("winrm e winrm/config/listener")
        server_def.should include("$fwrule = New-Object -ComObject HNetCfg.FwRule")
        server_def.should include("$fwrule.Name = \"knife-winrm\"")
        server_def.should include("$fwpolicy = New-Object -ComObject HNetCfg.FwPolicy2")
        server_def.should include("$fwpolicy.Rules.Add($fwrule)")
      end

      context "winrm-transport set to ssl" do
        before(:each) do
          @instance.config[:winrm_transport] = "ssl"
          @instance.config[:certificate_passwd] = "testwinrmcertgen"
          @instance.config[:cert_hostname_pattern] = "*.compute-1.amazonaws.com"
          @instance.config[:pfx_cert] = "C:\Users\cert.pfx"
          File.should_receive(:binread).with("C:\Users\cert.pfx").and_return(" \n")
          Base64.stub(:encode64).and_return("")
        end

        it "user data includes winrm ssl configuration commands" do
          @instance.config[:preserve_winrm_http] = false
          server_def = @instance.create_user_data
          server_def.should include("testuser_winrm")
          server_def.should include("winrm quickconfig -q")
          server_def.should include("winrm e winrm/config/listener")
          server_def.should include("winrm delete winrm/config/Listener?Address=*+Transport=HTTP")
          server_def.should include("$winrmcmd = \"winrm create winrm/config/listener?Address=*+Transport=HTTPS @{Hostname=`\"*.compute-1.amazonaws.com`\";CertificateThumbprint=`\"$thumbprint`\";Port=`\"5986`\"}\"")
          server_def.should include("$fwrule = New-Object -ComObject HNetCfg.FwRule")
          server_def.should include("$fwrule.LocalPorts = 5986")
          server_def.should include("$fwrule.Description = \"Open winrm ssl port\"")
        end

        it "user data includes winrm ssl configuration with preserve_winrm_http" do
          @instance.config[:preserve_winrm_http] = true
          server_def = @instance.create_user_data
          server_def.should include("testuser_winrm")
          server_def.should_not include("winrm delete winrm/config/Listener?Address=*+Transport=HTTP")
        end
      end
    end

    context "bootstrap protocol is ssh" do
      before(:all) do
        @instance = Chef::Knife::Cloud::ServerCreateCommand.new
        @instance.config[:bootstrap_protocol] = "ssh"
        @instance.config[:ssh_user] = "testuser_ssh"
        @instance.config[:ssh_password] = "testpassword_ssh"
      end

      it "user data include user create script for testuser_ssh" do
        server_def = @instance.create_user_data
        server_def.should include("testuser_ssh")
        server_def.should include("testpassword_ssh")
      end
    end
  end
end
