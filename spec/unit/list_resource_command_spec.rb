#
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
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

require 'spec_helper'
require 'chef/knife/cloud/list_resource_command'
require 'support/shared_examples_for_command'
require 'excon/errors'

describe Chef::Knife::Cloud::ResourceListCommand do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::ResourceListCommand.new

  let (:instance) {Chef::Knife::Cloud::ResourceListCommand.new}
  let (:resources) {[ TestResource.new({:id => "resource-1", :os => "ubuntu"}),
                   TestResource.new({:id => "resource-2", :os => "windows"})]}

  context "Basic tests:" do
    it "raises exception to override #query_resource method" do
      allow(instance).to receive(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
      expect {instance.run}.to raise_error(Chef::Exceptions::Override, "You must override query_resource in #{instance.to_s} to return resources.")
    end

    it "responds to #list method" do
      allow(instance).to receive(:query_resource)
      expect(instance).to respond_to(:list)
    end

    context "responds to #list method" do
      let(:test_resource) { "test" }
      before(:each) do
        expect(instance.ui).to receive(:fatal)
        instance.config[:format] = "summary"
      end

      it "handle generic exception" do
        allow(test_resource).to receive(:sort_by).and_raise StandardError
        expect {instance.list(test_resource)}.to raise_error(StandardError)
      end

      it "handle Excon::Errors::BadRequest exception." do
        allow(test_resource).to receive(:sort_by).and_raise Excon::Errors::BadRequest.new("excon error message")
        expect {instance.list(test_resource)}.to raise_error(Excon::Errors::BadRequest)
      end
    end
  end

  context "Without columns_with_info parameter in #list:" do
    before do
      allow(instance).to receive(:query_resource).and_return(resources)
      allow(instance).to receive(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
      allow(instance).to receive(:puts)
      instance.config[:format] = "summary"
    end

    it "lists resources in json format when columns_with_info parameter is empty" do
      expect(instance).to receive(:puts).with(resources[0].to_json)
      expect(instance).to receive(:puts).with(resources[1].to_json)
      expect(instance).to receive(:puts).with("\n").twice
      instance.run
    end
  end

  context "With columns_with_info parameter in #list:" do
    context "#value_callback not specified in columns_with_info" do
      before do
        class Derived < Chef::Knife::Cloud::ResourceListCommand
          attr_accessor :resource_filters
          def before_exec_command
            @columns_with_info = [ { :key => 'id', :label => 'Instance ID' },
                                 { :key => 'os', :label => 'Operating system' } ]
          end
        end

        @derived_instance = Derived.new
        allow(@derived_instance).to receive(:query_resource).and_return(resources)
        allow(@derived_instance).to receive(:puts)
        allow(@derived_instance).to receive(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
        @derived_instance.config[:format] = "summary"
      end

      it "lists all resources" do
        expect(@derived_instance.ui).to receive(:list).with(["Instance ID", "Operating system", "resource-1", "ubuntu", "resource-2", "windows"], :uneven_columns_across, 2)
        @derived_instance.run
      end

      it "excludes resource when filter is specified" do
        @derived_instance.resource_filters = [{:attribute => 'id', :regex => /^resource-1$/}]
        expect(@derived_instance.ui).to receive(:list).with(["Instance ID", "Operating system", "resource-2", "windows"], :uneven_columns_across, 2)
        @derived_instance.run
      end

      it "lists all resources when disable filter" do
        @derived_instance.config[:disable_filter] = true
        @derived_instance.resource_filters = [{:attribute => 'id', :regex => /^resource-1$/}]
        expect(@derived_instance.ui).to receive(:list).with(["Instance ID", "Operating system", "resource-1", "ubuntu", "resource-2", "windows"], :uneven_columns_across, 2)
        @derived_instance.run
      end
    end
    context "#value_callback specified in columns_with_info" do
      before do
        class Derived < Chef::Knife::Cloud::ResourceListCommand
          attr_accessor :resource_filters
          def before_exec_command
            @columns_with_info = [ { :key => 'id', :label => 'Instance ID' },
                               { :key => 'os', :label => 'Operating system', :value_callback => method(:format_os) } ]
          end
          def format_os(os)
            (os == 'ubuntu') ? "ubuntu - operating system with Linux kernel" : os
          end
        end

        @derived_instance = Derived.new
        allow(@derived_instance).to receive(:query_resource).and_return(resources)
        allow(@derived_instance).to receive(:puts)
        allow(@derived_instance).to receive(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
        @derived_instance.config[:format] = "summary"
      end

      it "lists formatted list of resources" do
        expect(@derived_instance.ui).to receive(:list).with(["Instance ID", "Operating system", "resource-1", "ubuntu - operating system with Linux kernel", "resource-2", "windows"], :uneven_columns_across, 2)
        @derived_instance.run
      end
    end
  end
end
