# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

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
      @instance.ui.stub(:error)
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