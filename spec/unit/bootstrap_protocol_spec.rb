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

require 'spec_helper'
require 'chef/knife/cloud/chefbootstrap/bootstrap_protocol'
require 'chef/knife/bootstrap'

describe Chef::Knife::Cloud::BootstrapProtocol do
  before do
    @config = {:bootstrap_protocol => 'ssh'}
    @instance = Chef::Knife::Cloud::BootstrapProtocol.new(@config)
  end

  context "BootstrapProtocol initializer" do
    it "asks for compulsory properties while creating @instance" do
      expect {Chef::Knife::Cloud::BootstrapProtocol.new}.to raise_error(ArgumentError)
    end

    it "creating @instance" do
      expect {Chef::Knife::Cloud::BootstrapProtocol.new(@config)}.to_not raise_error
      expect(Chef::Knife::Cloud::BootstrapProtocol.new(@config).class).to eq(Chef::Knife::Cloud::BootstrapProtocol)
    end
  end

  describe "#send_bootstrap_command" do
    it "execute with correct method calls" do
      @instance.bootstrap = double()
      expect(@instance).to receive(:wait_for_server_ready).ordered
      expect(@instance).to receive(:init_bootstrap_options).ordered
      expect(@instance.bootstrap).to receive(:run)
      @instance.send_bootstrap_command
    end
  end

  describe "#init_bootstrap_options" do
    it "set correct bootstrap config" do
      @config[:bootstrap_ip_address] = "127.0.0.1"
      @config[:chef_node_name] = "testnode"
      @config[:environment] = "_default"
      @config[:first_boot_attributes] = "{\"foo\":\"bar\"}"
      @config[:secret] = "secret"
      @config[:secret_file] = "secret_file"
      @config[:template_file] = "../template_file"
      @config[:bootstrap_vault_file] = "/foo/bar/baz"
      @config[:bootstrap_vault_json] = '{ "vault": "item1" }'
      @config[:bootstrap_vault_item] = { 'vault' => 'item1' }
      @config[:bootstrap_template] = "../template_file"
      @config[:node_ssl_verify_mode] = "none"
      @config[:node_verify_api_cert] = true
      @config[:bootstrap_url] = "https://www.chef.io/chef/install.sh"
      @config[:bootstrap_install_command] = "curl -l https://www.chef.io/chef/install.sh | sudo bash -s --"
      @config[:bootstrap_wget_options] = "-e use_proxy=yes -e http://myproxy.com:8080"
      @config[:bootstrap_curl_options] = "--proxy http://myproxy.com:8080"
      @config[:use_sudo_password] = "true"
      @config[:msi_url] = "https://opscode-omnibus-packages.s3.amazonaws.com/windows/2008r2/x86_64/chef-client-12.3.0-1.msi"
      @config[:session_timeout] = "42"
      @config[:install_as_service] = "true"
      allow(@config).to receive(:locate_config_value).and_return({})
      @instance.bootstrap = Chef::Knife::Bootstrap.new
      @instance.init_bootstrap_options
      expect(@instance.bootstrap.name_args).to eq([@config[:bootstrap_ip_address]])
      expect(@instance.bootstrap.config[:chef_node_name]).to eq(@config[:chef_node_name])
      expect(@instance.bootstrap.config[:environment]).to eq(@config[:environment])
      expect(@instance.bootstrap.config[:first_boot_attributes]).to eq(@config[:first_boot_attributes])
      expect(@instance.bootstrap.config[:secret]).to eq(@config[:secret])
      expect(@instance.bootstrap.config[:secret_file]).to eq(@config[:secret_file])
      expect(@instance.bootstrap.config[:template_file]).to eq(@config[:template_file])
      expect(@instance.bootstrap.config[:bootstrap_vault_file]).to eq(@config[:bootstrap_vault_file])
      expect(@instance.bootstrap.config[:bootstrap_vault_json]).to eq(@config[:bootstrap_vault_json])
      expect(@instance.bootstrap.config[:bootstrap_vault_item]).to eq(@config[:bootstrap_vault_item])
      expect(@instance.bootstrap.config[:bootstrap_template]).to eq(@config[:bootstrap_template])
      expect(@instance.bootstrap.config[:node_ssl_verify_mode]).to eq(@config[:node_ssl_verify_mode])
      expect(@instance.bootstrap.config[:node_verify_api_cert]).to eq(@config[:node_verify_api_cert])
      expect(@instance.bootstrap.config[:bootstrap_url]).to eq(@config[:bootstrap_url])
      expect(@instance.bootstrap.config[:bootstrap_install_command]).to eq(@config[:bootstrap_install_command])
      expect(@instance.bootstrap.config[:bootstrap_wget_options]).to eq(@config[:bootstrap_wget_options])
      expect(@instance.bootstrap.config[:bootstrap_curl_options]).to eq(@config[:bootstrap_curl_options])
      expect(@instance.bootstrap.config[:use_sudo_password]).to eq(@config[:use_sudo_password])
      expect(@instance.bootstrap.config[:msi_url]).to eq(@config[:msi_url])
      expect(@instance.bootstrap.config[:install_as_service]).to eq(@config[:install_as_service])
      expect(@instance.bootstrap.config[:session_timeout]).to eq(@config[:session_timeout])
    end
  end
end
