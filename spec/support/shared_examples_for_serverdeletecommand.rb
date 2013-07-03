# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'chef/knife/cloud/server/delete_command'

shared_examples_for Chef::Knife::Cloud::ServerDeleteCommand do |instance|
  it "calls after_handler to delete server from chef" do

  end

  it "expects chef warning message when purge option is disabled" do

  end

  it "deletes chef node and client when purge option is enabled" do


  end

  it "deletes chef node specified with node-name option overriding the instance server_name" do

  end
end
