#
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright (c) 2013 Chef Software, Inc.
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

require 'spec_helper'
require 'chef/knife/cloud/chefbootstrap/unix_distribution'

describe Chef::Knife::Cloud::UnixDistribution do

  before do
    @config = {:bootstrap_protocol => 'ssh'}
  end

  context "Unix Distribution initializer" do
    it "asks for compulsory properties while creating instance" do
      expect {Chef::Knife::Cloud::UnixDistribution.new}.to raise_error(ArgumentError)
    end

    it "creates instance" do
      expect {Chef::Knife::Cloud::UnixDistribution.new(@config)}.to_not raise_error
      expect(Chef::Knife::Cloud::UnixDistribution.new(@config).class).to eq(Chef::Knife::Cloud::UnixDistribution)
    end
  end
end
