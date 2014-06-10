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

describe Chef::Knife::Cloud::Command do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::Command.new
  
  describe "validate!" do
    before(:each) do
      # Here following options are used as a test data.
      Chef::Config[:knife][:cloud_provider_username] = "cloud_provider_username"
      Chef::Config[:knife][:cloud_provider_password] = "cloud_provider_password"
      Chef::Config[:knife][:cloud_provider_auth_url] = "cloud_provider_auth_url"
      @instance = Chef::Knife::Cloud::Command.new
      allow(@instance.ui).to receive(:error)
    end
    
    after(:all) do
      Chef::Config[:knife].delete(:cloud_provider_username)
      Chef::Config[:knife].delete(:cloud_provider_password)
      Chef::Config[:knife].delete(:cloud_provider_auth_url)
    end

    it "execute with success" do
      expect { @instance.validate!(:cloud_provider_username, :cloud_provider_password, :cloud_provider_auth_url) }.to_not raise_error 
    end

    it "raise_error on any mandatory option is missing" do
      # delete cloud_provide_username option.
      Chef::Config[:knife].delete(:cloud_provider_username)
      expect { @instance.validate!(:cloud_provider_username, :cloud_provider_password, :cloud_provider_auth_url) }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ValidationError, " You did not provide a valid 'Cloud Provider Username' value..")
    end
  end
end