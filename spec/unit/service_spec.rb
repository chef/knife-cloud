# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'chef/knife/cloud/service'


describe Chef::Knife::Cloud::Service do

 let (:instance) { Chef::Knife::Cloud::Service.new }

 it { expect {instance}.to_not raise_error }

 it { expect {instance.connection}.to raise_error(Chef::Exceptions::Override, "You must override connection in #{instance.to_s}") }

 it { expect {instance.create_server}.to raise_error(Chef::Exceptions::Override, "You must override create_server in #{instance.to_s}") }

 it { expect {instance.delete_server(:server_name)}.to raise_error(Chef::Exceptions::Override, "You must override delete_server in #{instance.to_s}") }

 it { expect {instance.delete_server}.to raise_error(ArgumentError, "wrong number of arguments (0 for 1)") }

 it { expect {instance.list_servers}.to raise_error(Chef::Exceptions::Override, "You must override list_servers in #{instance.to_s}") }

 it { expect {instance.list_images}.to raise_error(ArgumentError, "wrong number of arguments (0 for 1)") }

 it { expect {instance.list_images(:image_filters)}.to raise_error(Chef::Exceptions::Override, "You must override list_images in #{instance.to_s}") }

it { expect {instance.list_resource_configurations()}.to raise_error(Chef::Exceptions::Override, "You must override list_resource_configurations in #{instance.to_s}") }

 it { expect { Chef::Knife::Cloud::Service.new({:auth_params => {:provider => 'Any Cloud Provider'}}) }.to_not raise_error }

end
