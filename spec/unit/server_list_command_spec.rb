# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'spec_helper'
require 'support/shared_examples_for_command'
require 'chef/knife/cloud/server/list_command'
require 'chef/node'

describe Chef::Knife::Cloud::ServerListCommand do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::ServerListCommand.new

  describe "#before_exec_command" do
    it "set chef data columns info on chef data options" do
      instance = Chef::Knife::Cloud::ServerListCommand.new
      instance.config[:chef_data] = true
      Chef::Node.should_receive(:list).with(true)
      instance.before_exec_command.should include({:label => "Chef Node Name", :key => "name"})
    end

    it "set chef data columns info on chef-data and chef-node-attribute options" do
      chef_node_attribute = "platform_family"
      instance = Chef::Knife::Cloud::ServerListCommand.new
      instance.config[:chef_data] = true
      instance.config[:chef_node_attribute] = chef_node_attribute
      Chef::Node.should_receive(:list).with(true)
      instance.before_exec_command.should include({:label => chef_node_attribute, :key => chef_node_attribute})
    end

    it "not set chef data columns info if chef-data option is not set" do
      instance = Chef::Knife::Cloud::ServerListCommand.new
      Chef::Node.should_not_receive(:list).with(true)
      instance.before_exec_command.should be(nil)
    end

    it "not set chef data columns info on chef-node-attribute option set but chef-data option is not set" do
      instance = Chef::Knife::Cloud::ServerListCommand.new
      instance.config[:chef_node_attribute] = "platform_family"
      Chef::Node.should_not_receive(:list).with(true)
      instance.before_exec_command.should be(nil)
    end
  end

  describe "#get_resource_col_val" do
    let (:resources) {[ TestResource.new({:id => "server-1", :name => "server-1", :os => "ubuntu"})]}
    before do
      class DerivedServerList < Chef::Knife::Cloud::ServerListCommand
        attr_accessor :node
        def before_exec_command
          @columns_with_info = [ { :key => 'id', :label => 'Instance ID' }, {:label => 'Environment', :key => 'chef_environment'}, {:label => 'platform_family', :key => 'platform_family'} ]
          @chef_data_col_info = [ {:label => 'Environment', :key => 'chef_environment'}, {:label => 'platform_family', :key => 'platform_family'} ]
          @node = TestResource.new({:id => "server-1", :name => "server-1",
          :chef_environment => "_default", :platform_family => "debian"})
          @node.define_singleton_method(:attribute?) do |attribute|
          end
          @node_list = {"server-1" => @node}
        end
      end
      @derived_instance = DerivedServerList.new
      @derived_instance.config[:chef_data] = true
      @derived_instance.config[:chef_node_attribute] = "platform_family"
      @derived_instance.before_exec_command
      @derived_instance.service = double Chef::Knife::Cloud::Service.new
      @derived_instance.service.stub(:get_server_name).with(resources.first).and_return("server-1")
    end

    it "return columns_with_info values" do
      @derived_instance.node.should_receive(:attribute?).with("platform_family").and_return(true)
      @derived_instance.get_resource_col_val(resources.first).should eq(["server-1", "_default", "debian"])
    end

    it "raise error on invalide chef_node_attribute" do
      @derived_instance.ui.stub(:error)
      @derived_instance.node.should_receive(:attribute?).with("platform_family").and_return(false)
      expect { @derived_instance.get_resource_col_val(resources.first) }.to raise_error(Chef::Knife::Cloud::CloudExceptions::CloudAPIException, "The Node does not have a platform_family attribute.")
    end    
  end

  describe "#format_server_state" do
    before(:each) do
      @instance = Chef::Knife::Cloud::ServerListCommand.new 
    end

    %w{ shutting-down terminated stopping stopped error shutoff }.each do |state|
      it "set state color red on server state is in #{state}" do
        @instance.ui.should_receive(:color).with(state, :red)
        @instance.format_server_state(state)
      end
    end

    %w{ pending build paused suspended hard_reboot }.each do |state|
      it "set state color yellow on server state is in #{state}" do
        @instance.ui.should_receive(:color).with(state, :yellow)
        @instance.format_server_state(state)
      end
    end

    %w{ running }.each do |state|
      it "set state color green on server state is #{state}" do
        @instance.ui.should_receive(:color).with(state, :green)
        @instance.format_server_state(state)
      end
    end
  end
end
