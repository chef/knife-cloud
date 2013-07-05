# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'spec_helper'
require 'support/shared_examples_for_command'
require 'support/shared_examples_for_serverdeletecommand'

describe Chef::Knife::Cloud::ServerDeleteCommand do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::ServerDeleteCommand.new
  it_behaves_like Chef::Knife::Cloud::ServerDeleteCommand, Chef::Knife::Cloud::ServerDeleteCommand.new
end
