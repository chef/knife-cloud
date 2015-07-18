#
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
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

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'chef/knife/cloud/fog/service'
require 'support/shared_examples_for_service'

describe Chef::Knife::Cloud::FogService do

  it_behaves_like Chef::Knife::Cloud::Service, Chef::Knife::Cloud::FogService.new

  let (:instance) { Chef::Knife::Cloud::FogService.new({:auth_params => {:provider => 'Any Cloud Provider'}}) }

  context "connection" do
    before do
      allow(instance).to receive(:exit)
    end

    it "creates a connection to fog service with the provided auth params." do
      expect(instance).to receive(:add_api_endpoint)
      expect(Fog::Compute).to receive(:new).with({:provider => 'Any Cloud Provider'})
      instance.connection
    end
  end

  context "network" do
    it "creates a connection to fog network with the provided auth params." do
      expect(Fog::Network).to receive(:new).with({:provider => 'Any Cloud Provider'})
      instance.network
    end

    context "connection to fog" do
      before do
        allow(instance).to receive(:exit)
        allow(instance).to receive(:ui).and_return(Object.new)
        expect(instance.ui).to receive(:fatal)
      end

      it "handles Unauthorized exception." do
        expect(Fog::Network).to receive(:new).with({:provider => 'Any Cloud Provider'}).and_raise Excon::Errors::Unauthorized.new("Unauthorized")
        expect {instance.network}.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServiceConnectionError)
      end

      it "handles SocketError or any other connection exception." do
        socket_error = Excon::Errors::SocketError.new(Exception.new "Mock Error")
        expect(Fog::Network).to receive(:new).with({:provider => 'Any Cloud Provider'}).and_raise socket_error
        expect {instance.network}.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServiceConnectionError)
      end

      it "handles NetworkNotFoundError exception." do
        expect(Fog::Network).to receive(:new).with({:provider => 'Any Cloud Provider'}).and_raise Fog::Errors::NotFound.new("NotFound")
        expect {instance.network}.to raise_error(Chef::Knife::Cloud::CloudExceptions::NetworkNotFoundError)
      end
    end
  end

  context "add_custom_attributes" do
    before(:each) do
      Chef::Config[:knife][:custom_attributes] = [{"state"=>"Inactive"}]
      @server_def = {:name=>"vm-1", :image_ref=>"123",:flavor_ref=>"2", :key_name=>"key"}
      instance.add_custom_attributes(@server_def)
    end

    it "adds the custom attributes provided to server_def" do
      expect(@server_def.include?(:state)).to be true
    end

    it "sets the provided attributes with supplied values" do
      expect(@server_def[:state] == "Inactive").to be true
    end
  end

  ["servers", "images", "networks"].each do |resource_type|
    resource =  case resource_type
                when "networks"
                  :network
                else
                  :connection
                end
    context "list #{resource_type}" do

      it "lists #{resource_type} of the current cloud service provider account." do
        allow(instance).to receive_message_chain(resource.to_sym, "#{resource_type}".to_sym, :all)
        instance.method("list_#{resource_type}").call
      end

      it "handles Excon::Errors::BadRequest exception." do
        allow(instance).to receive(:ui).and_return(Object.new)
        allow(instance.ui).to receive(:fatal)
        allow(instance).to receive_message_chain(resource.to_sym, "#{resource_type}".to_sym, :all).and_raise Excon::Errors::BadRequest.new("Invalid Resource")
        expect {instance.method("list_#{resource_type}").call}.to raise_error(Chef::Knife::Cloud::CloudExceptions::CloudAPIException)
      end
    end
  end

  context "#delete_server" do
    before(:each) do
      @server = TestResource.new({:id => "test-server1"})
      @server.define_singleton_method(:destroy){}
    end

    it "delete instance successfully" do
      server_name = "test-server1"
      instance.ui = double
      expect(instance).to receive(:get_server).and_return(@server)
      expect(instance).to receive(:get_server_name).and_return(server_name)
      expect(instance).to receive(:msg_pair).with("Instance Name", server_name)
      expect(instance).to receive(:msg_pair).with("Instance ID", @server.id)
      expect(instance.ui).to receive(:confirm)
      expect(@server).to receive(:destroy)
      instance.delete_server(server_name)
    end

    it "raise_error on non existence server delete " do
      server_name = "test-server1"
      instance.ui = double
      error_message = "Could not locate server '#{server_name}'."
      expect(instance).to receive(:get_server).and_return(nil)
      expect(instance.ui).to receive(:error).with(error_message)
      expect { instance.delete_server(server_name) }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServerDeleteError, error_message)
    end
  end

  context '#release_address' do
    before(:each) do
      allow(instance).to receive(:add_api_endpoint)
      allow(Fog::Compute).to receive(:new).with({:provider => 'Any Cloud Provider'})
    end

    it 'releases address successfully' do
      address_id = 'test-addres-id'
      @address = TestResource.new('body' => { 'floating_ip' =>
                                            { 'instance_id' => nil,
                                              'ip' => '127.0.0.1',
                                              'fixed_ip' => nil,
                                              'id' => 'test-addres-id',
                                              'pool' => 'public-110'
                                            }
                                          })
      instance.ui = double
      expect(instance).to receive(:get_address).and_return(@address)
      expect(instance).to receive(:msg_pair).with('IP address', '127.0.0.1')
      expect(instance.ui).to receive(:confirm)
      allow(instance.connection).to receive(:release_address)
      instance.release_address(address_id)
    end
  end
end
