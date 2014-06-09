#
# Author:: Mukta Aphale (<mukta.aphale@clogeny.com>)
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
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::Command do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::Command.new

  let (:instance) { Chef::Knife::Cloud::Command.new }

  it "overrides execute_command" do
    allow(instance).to receive(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
    expect {instance.run}.to raise_error(Chef::Exceptions::Override, "You must override execute_command in #{instance.to_s}")
  end

  it { expect {instance.run}.to raise_error(Chef::Exceptions::Override, "You must override create_service_instance in #{instance.to_s} to create cloud specific service") }

end

