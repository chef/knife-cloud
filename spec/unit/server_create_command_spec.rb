# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'support/shared_examples_for_command'
require 'support/shared_examples_for_servercreatecommand'

describe Chef::Knife::Cloud::ServerCreateCommand do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::ServerCreateCommand.new
  it_behaves_like Chef::Knife::Cloud::ServerCreateCommand, Chef::Knife::Cloud::ServerCreateCommand.new
end
