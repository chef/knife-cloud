require 'spec_helper'
require 'chef/knife/cloud/chefbootstrap/bootstrap_protocol'
require 'chef/knife/bootstrap'

describe Chef::Knife::Cloud::BootstrapProtocol do
  before do
    # setup dummy objects.
    @app = App.new
    @instance = Chef::Knife::Cloud::BootstrapProtocol.new(@app)
  end

  context "BootstrapProtocol initializer" do
    it "asks for compulsory properties while creating instance" do
      expect {Chef::Knife::Cloud::BootstrapProtocol.new}.to raise_error(ArgumentError)
    end

    it "creating instance" do
      expect {Chef::Knife::Cloud::BootstrapProtocol.new(@app)}.to_not raise_error
      expect(Chef::Knife::Cloud::BootstrapProtocol.new(@app).class).to eq(Chef::Knife::Cloud::BootstrapProtocol)
    end
  end

  describe "#send_bootstrap_command" do
    it "execute with correct method calls" do
      @instance.bootstrap = mock()
      @instance.should_receive(:wait_for_server_ready).ordered
      @instance.should_receive(:init_bootstrap_options).ordered
      @instance.bootstrap.should_receive(:run)
      @instance.send_bootstrap_command
    end
  end

  describe "#init_bootstrap_options" do
    it "set correct bootstrap config" do
      @app.config[:bootstrap_ip_address] = "127.0.0.1"
      @app.config[:chef_node_name] = "testnode"
      @app.config[:environment] = "_default"
      @app.stub(:locate_config_value).and_return({})
      @instance.bootstrap = Chef::Knife::Bootstrap.new
      @instance.init_bootstrap_options
      expect(@instance.bootstrap.name_args).to eq(@app.config[:bootstrap_ip_address])
      expect(@instance.bootstrap.config[:chef_node_name]).to eq(@app.config[:chef_node_name])
      expect(@instance.bootstrap.config[:environment]).to eq(@app.config[:environment])
    end
  end
end
