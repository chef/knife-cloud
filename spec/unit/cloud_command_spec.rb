# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::Command do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::Command.new

  let (:instance) { Chef::Knife::Cloud::Command.new }

  it "overrides execute_command" do
    instance.stub(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
    expect {instance.run}.to raise_error(Chef::Exceptions::Override, "You must override execute_command in #{instance.to_s}")
  end

  it { expect {instance.run}.to raise_error(Chef::Exceptions::Override, "You must override create_service_instance in #{instance.to_s} to create cloud specific service") }

end

