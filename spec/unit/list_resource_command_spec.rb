# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'spec_helper'
require 'chef/knife/cloud/list_resource_command'

describe Chef::Knife::Cloud::ResourceListCommand do

  before do
    # setup dummy app and service objects.
    @app = App.new
    @service = Object.new
    @instance = Chef::Knife::Cloud::ResourceListCommand.new(@app, @service)
    @resources = [ TestResource.new({:id => "resource-1", :os => "ubuntu"}),
                   TestResource.new({:id => "resource-2", :os => "windows"})]
  end

  context "Basic tests:" do
    it {expect {Chef::Knife::Cloud::ResourceListCommand.new}.to raise_error(ArgumentError, "wrong number of arguments (0 for 2)")}

    it "raises exception to override #query_resource method" do
      @instance.stub(:list)
      expect {@instance.run}.to raise_error(Chef::Exceptions::Override, "You must override query_resource in #{@instance.to_s} to return resources.")
    end

    it "sets sort_by_field attribute to 'id' by default" do
      expect(@instance.sort_by_field).to eql('id')
    end

    it "responds to #list method" do
      @instance.stub(:query_resource)
      @instance.should respond_to(:list)
    end
  end

  context "Without columns_with_info parameter in #list:" do
    before do
      @instance.stub(:query_resource).and_return(@resources)
      @instance.stub(:puts)
    end

    it "lists resources in json format when columns_with_info parameter is empty" do
      @instance.should_receive(:puts).with(@resources[0].to_json)
      @instance.should_receive(:puts).with(@resources[1].to_json)
      @instance.should_receive(:puts).with("\n").twice
      @instance.run
    end
  end

  context "With columns_with_info parameter in #list:" do
    context "#value_callback not specified in columns_with_info" do
      before do
        class Derived < Chef::Knife::Cloud::ResourceListCommand
          def list(resources, columns_with_info = [])
            super(resources, [ { :key => 'id', :label => 'Instance ID' },
                               { :key => 'os', :label => 'Operating system' } ]
            )  # inject for tests
          end
        end

        @derived_instance = Derived.new(@app, @service)
        @derived_instance.stub(:query_resource).and_return(@resources)
        @derived_instance.stub(:puts)
      end

      it "lists all resources" do
        @derived_instance.ui.should_receive(:list).with(["Instance ID", "Operating system", "resource-1", "ubuntu", "resource-2", "windows"], :uneven_columns_across, 2)
        @derived_instance.run
      end

      it "excludes resource when filter is specified" do
        filters = [{:attribute => 'id', :regex => /^resource-1$/}]
        @derived_instance.ui.should_receive(:list).with(["Instance ID", "Operating system", "resource-2", "windows"], :uneven_columns_across, 2)
        @derived_instance.run(filters)
      end

      it "lists all resources when disable filter" do
        @app.config[:disable_filter] = true
        filters = [{:attribute => 'id', :regex => /^resource-1$/}]
        @derived_instance.ui.should_receive(:list).with(["Instance ID", "Operating system", "resource-1", "ubuntu", "resource-2", "windows"], :uneven_columns_across, 2)
        @derived_instance.run(filters)
      end
    end
    context "#value_callback specified in columns_with_info" do
      before do
        class Derived < Chef::Knife::Cloud::ResourceListCommand
          def list(resources, columns_with_info = [])
            super(resources, [ { :key => 'id', :label => 'Instance ID' },
                               { :key => 'os', :label => 'Operating system', :value_callback => method(:format_os) } ]
            )  # inject for tests
          end
          def format_os(os)
            (os == 'ubuntu') ? "ubuntu - operating system with Linux kernel" : os
          end
        end

        @derived_instance = Derived.new(@app, @service)
        @derived_instance.stub(:query_resource).and_return(@resources)
        @derived_instance.stub(:puts)
      end

      it "lists formatted list of resources" do
        @derived_instance.ui.should_receive(:list).with(["Instance ID", "Operating system", "resource-1", "ubuntu - operating system with Linux kernel", "resource-2", "windows"], :uneven_columns_across, 2)
        @derived_instance.run
      end
    end
  end
end
