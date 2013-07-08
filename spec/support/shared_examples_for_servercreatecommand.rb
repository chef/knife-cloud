# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'spec_helper'
require 'chef/knife/cloud/server/create_command'

shared_examples_for Chef::Knife::Cloud::ServerCreateCommand do |instance|
  before do
    instance.service = mock()
  end

  describe "#before_exec_command" do
    it "calls create_server_dependencies" do
      instance.service.should_receive(:create_server_dependencies)
      instance.before_exec_command
    end
    it "raises error" do
      #instance.service.should_receive(:create_server_dependencies).and_raise(Chef::Knife::Cloud::CloudExceptions::ServerCreateDependenciesError.new("Error"))
      #instance.service.should_receive(:delete_server_dependencies)
      #instance.before_exec_command
    end
  end

end
