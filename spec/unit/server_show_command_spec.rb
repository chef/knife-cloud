#
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

require 'support/shared_examples_for_command'
require 'chef/knife/cloud/server/show_command'

describe Chef::Knife::Cloud::ServerShowCommand do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::ServerShowCommand.new
  
  describe "#validate_params!" do
    before(:each) do
      @instance = Chef::Knife::Cloud::ServerShowCommand.new
      allow(@instance.ui).to receive(:error)
      Chef::Config[:knife][:instance_id] = "instance_id"
    end
    after(:all) do
      Chef::Config[:knife].delete(:instance_id)
    end

    it "run sucessfully on all params exist" do
      expect { @instance.validate_params! }.to_not raise_error
    end

    it "raise error on missing instance_id param" do
      Chef::Config[:knife].delete(:instance_id)
      expect { @instance.validate_params! }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError, " You must provide a valid Instance Id.")
    end
  end

  describe "#execute_command" do
    it "show server summary" do
      instance = Chef::Knife::Cloud::ServerShowCommand.new
      instance.service = Chef::Knife::Cloud::Service.new
      server = Object.new
      expect(instance.service).to receive(:get_server).and_return(server)
      expect(instance.service).to receive(:server_summary)
      instance.execute_command
    end

    it "raise error on invalid instance id" do
      instance = Chef::Knife::Cloud::ServerShowCommand.new
      instance.service = Chef::Knife::Cloud::Service.new
      Chef::Config[:knife][:instance_id] = "invalid_id"
      allow(instance.ui).to receive(:error)
      expect(instance.service).to receive(:get_server).and_return(nil)
      expect(instance.service).to_not receive(:server_summary)
      expect { instance.execute_command }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServerShowError, "Server doesn't exists for this invalid_id instance id.")
    end    
  end
end