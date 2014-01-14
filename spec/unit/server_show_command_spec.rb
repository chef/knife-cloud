# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'support/shared_examples_for_command'
require 'chef/knife/cloud/server/show_command'

describe Chef::Knife::Cloud::ServerShowCommand do
  it_behaves_like Chef::Knife::Cloud::Command, Chef::Knife::Cloud::ServerShowCommand.new
  
  describe "#validate_params!" do
    before(:each) do
      @instance = Chef::Knife::Cloud::ServerShowCommand.new
      @instance.ui.stub(:error)
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
      instance.service.should_receive(:get_server).and_return(server)
      instance.service.should_receive(:server_summary)
      instance.execute_command
    end

    it "raise error on invalid instance id" do
      instance = Chef::Knife::Cloud::ServerShowCommand.new
      instance.service = Chef::Knife::Cloud::Service.new
      Chef::Config[:knife][:instance_id] = "invalid_id"
      instance.ui.stub(:error)
      instance.service.should_receive(:get_server).and_return(nil)
      instance.service.should_not_receive(:server_summary)
      expect { instance.execute_command }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServerShowError, "Server doesn't exists for this invalid_id instance id.")
    end    
  end
end