require 'spec_helper'
require 'chef/knife/cloud/chefbootstrap/bootstrap_protocol'
require 'chef/knife/bootstrap'

describe Chef::Knife::Cloud::BootstrapProtocol do
  before do
    @config = {:bootstrap_protocol => 'ssh'}
    @instance = Chef::Knife::Cloud::BootstrapProtocol.new(@config)
  end

  context "BootstrapProtocol initializer" do
    it "asks for compulsory properties while creating @instance" do
      expect {Chef::Knife::Cloud::BootstrapProtocol.new}.to raise_error(ArgumentError)
    end

    it "creating @instance" do
      expect {Chef::Knife::Cloud::BootstrapProtocol.new(@config)}.to_not raise_error
      expect(Chef::Knife::Cloud::BootstrapProtocol.new(@config).class).to eq(Chef::Knife::Cloud::BootstrapProtocol)
    end
  end

  describe "#send_bootstrap_command" do
    it "execute with correct method calls" do
      @instance.bootstrap = double()
      @instance.should_receive(:wait_for_server_ready).ordered
      @instance.should_receive(:init_bootstrap_options).ordered
      @instance.bootstrap.should_receive(:run)
      @instance.send_bootstrap_command
    end
  end

  describe "#init_bootstrap_options" do
    it "set correct bootstrap config" do
      @config[:bootstrap_ip_address] = "127.0.0.1"
      @config[:chef_node_name] = "testnode"
      @config[:environment] = "_default"
      @config[:first_boot_attributes] = "{\"foo\":\"bar\"}"
      @config[:secret] = "secret"
      @config[:secret_file] = "secret_file"
      @config.stub(:locate_config_value).and_return({})
      @instance.bootstrap = Chef::Knife::Bootstrap.new
      @instance.init_bootstrap_options
      expect(@instance.bootstrap.name_args).to eq(@config[:bootstrap_ip_address])
      expect(@instance.bootstrap.config[:chef_node_name]).to eq(@config[:chef_node_name])
      expect(@instance.bootstrap.config[:environment]).to eq(@config[:environment])
      expect(@instance.bootstrap.config[:first_boot_attributes]).to eq(@config[:first_boot_attributes])
      expect(@instance.bootstrap.config[:secret]).to eq(@config[:secret])
      expect(@instance.bootstrap.config[:secret_file]).to eq(@config[:secret_file])
    end
  end
end
