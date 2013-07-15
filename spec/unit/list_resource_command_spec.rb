# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'spec_helper'
require 'chef/knife/cloud/list_resource_command'
require 'support/shared_examples_for_command'

describe Chef::Knife::Cloud::ResourceListCommand do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::ResourceListCommand.new
  
  let (:instance) {Chef::Knife::Cloud::ResourceListCommand.new}
  let (:resources) {[ TestResource.new({:id => "resource-1", :os => "ubuntu"}),
                   TestResource.new({:id => "resource-2", :os => "windows"})]}

  context "Basic tests:" do
    it "raises exception to override #query_resource method" do
      instance.stub(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
      expect {instance.run}.to raise_error(Chef::Exceptions::Override, "You must override query_resource in #{instance.to_s} to return resources.")
    end

    it "responds to #list method" do
      instance.stub(:query_resource)
      instance.should respond_to(:list)
    end
  end

  context "Without columns_with_info parameter in #list:" do
    before do
      instance.stub(:query_resource).and_return(resources)
      instance.stub(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
      instance.stub(:puts)
    end

    it "lists resources in json format when columns_with_info parameter is empty" do
      instance.should_receive(:puts).with(resources[0].to_json)
      instance.should_receive(:puts).with(resources[1].to_json)
      instance.should_receive(:puts).with("\n").twice
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
        @derived_instance.stub(:query_resource).and_return(resources)
        @derived_instance.stub(:puts)
        @derived_instance.stub(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
      end

      it "lists all resources" do
        @derived_instance.ui.should_receive(:list).with(["Instance ID", "Operating system", "resource-1", "ubuntu", "resource-2", "windows"], :uneven_columns_across, 2)
        @derived_instance.run
      end

      it "excludes resource when filter is specified" do
        @derived_instance.resource_filters = [{:attribute => 'id', :regex => /^resource-1$/}]
        @derived_instance.ui.should_receive(:list).with(["Instance ID", "Operating system", "resource-2", "windows"], :uneven_columns_across, 2)
        @derived_instance.run
      end

      it "lists all resources when disable filter" do
        @derived_instance.config[:disable_filter] = true
        @derived_instance.resource_filters = [{:attribute => 'id', :regex => /^resource-1$/}]
        @derived_instance.ui.should_receive(:list).with(["Instance ID", "Operating system", "resource-1", "ubuntu", "resource-2", "windows"], :uneven_columns_across, 2)
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
        @derived_instance.stub(:query_resource).and_return(resources)
        @derived_instance.stub(:puts)
        @derived_instance.stub(:create_service_instance).and_return(Chef::Knife::Cloud::Service.new)
      end

      it "lists formatted list of resources" do
        @derived_instance.ui.should_receive(:list).with(["Instance ID", "Operating system", "resource-1", "ubuntu - operating system with Linux kernel", "resource-2", "windows"], :uneven_columns_across, 2)
        @derived_instance.run
      end
    end
  end
end
