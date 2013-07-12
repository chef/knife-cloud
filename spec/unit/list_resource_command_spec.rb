# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'spec_helper'
require 'chef/knife/cloud/list_resource_command'
require 'support/shared_examples_for_listresourcecommand'

describe Chef::Knife::Cloud::ResourceListCommand do
  it_behaves_like Chef::Knife::Cloud::ResourceListCommand, Chef::Knife::Cloud::ResourceListCommand.new
end
