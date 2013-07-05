# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'chef/knife/cloud/server/delete_command'

shared_examples_for Chef::Knife::Cloud::ServerDeleteCommand do |instance|
  describe "#delete_from_chef" do
    it "expects chef warning message when purge option is disabled" do
      server_name = "testserver"
      instance.ui.should_receive(:warn).with("Corresponding node and client for the #{server_name} server were not deleted and remain registered with the Chef Server")
      instance.delete_from_chef(server_name)
    end

    it "deletes chef node and client when purge option is enabled" do
      instance.config[:purge] = true
      server_name = "testserver"
      instance.should_receive(:destroy_item).with(Chef::Node, server_name, "node").ordered
      instance.should_receive(:destroy_item).with(Chef::ApiClient, server_name, "client").ordered
      instance.delete_from_chef(server_name)
    end

    it "deletes chef node specified with node-name option overriding the instance server_name" do
      instance.config[:purge] = true
      server_name = "testserver"
      chef_node_name = "testnode"
      instance.config[:chef_node_name] = chef_node_name
      instance.should_receive(:destroy_item).with(Chef::Node, chef_node_name, "node").ordered
      instance.should_receive(:destroy_item).with(Chef::ApiClient, chef_node_name, "client").ordered
      instance.delete_from_chef(chef_node_name)
    end
  end

  describe "#execute_command" do
    it "execute with correct method calls" do
      instance::name_args = ["testserver"]
      instance.service = mock
      instance.service.should_receive(:delete_server).ordered
      instance.should_receive(:delete_from_chef).ordered
      instance.execute_command
    end
  end

  describe "#destroy_item" do
    it "destroy chef node" do
      node_name = "testnode"
      test_obj = Object.new
      Chef::Node.stub(:load).and_return(test_obj)
      test_obj.stub(:destroy)
      instance.ui.should_receive(:warn).with("Deleted node #{node_name}")
      instance.destroy_item(Chef::Node, node_name, "node")
    end

    it "destroy chef client" do
      client_name = "testclient"
      test_obj = Object.new
      Chef::ApiClient.stub(:load).and_return(test_obj)
      test_obj.stub(:destroy)
      instance.ui.should_receive(:warn).with("Deleted client #{client_name}")
      instance.destroy_item(Chef::ApiClient, client_name, "client")
    end
  end  
end
