# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
#
# Copyright:: Copyright (c) 2013 Opscode, Inc.
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
#

require 'chef/knife/core/ui'
require 'chef/knife/cloud/helpers'

class Chef
  class Knife
    class Cloud
      class BootstrapProtocol
        include Chef::Knife::Cloud::Helpers

        attr_accessor :bootstrap, :ui, :initial_sleep_delay
        attr_reader :config

        def initialize(config)
          @config = config
          @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
        end

        def wait_for_server_ready
          raise Chef::Exceptions::Override, "You must override wait_for_server_ready in #{self.to_s}"
        end

        def send_bootstrap_command
          wait_for_server_ready
          init_bootstrap_options
          @bootstrap.run
        end

        def init_bootstrap_options
          # set the command bootstrap options.
          bootstrap.name_args << locate_config_value(:bootstrap_ip_address)
          bootstrap.config[:chef_node_name] = locate_config_value(:chef_node_name)
          bootstrap.config[:run_list] = locate_config_value(:run_list)
          bootstrap.config[:prerelease] = locate_config_value(:prerelease)
          bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
          bootstrap.config[:distro] = locate_config_value(:distro)
          bootstrap.config[:bootstrap_proxy] = locate_config_value(:bootstrap_proxy)
          bootstrap.config[:environment] = locate_config_value(:environment)
          # see chef/knife/bootstrap.rb #warn_chef_config_secret_key.
          bootstrap.config[:encrypted_data_bag_secret] = locate_config_value(:encrypted_data_bag_secret)
          bootstrap.config[:encrypted_data_bag_secret_file] = locate_config_value(:encrypted_data_bag_secret_file)
          bootstrap.config[:first_boot_attributes] = locate_config_value(:first_boot_attributes)
          bootstrap.config[:secret] = locate_config_value(:secret)
          bootstrap.config[:secret_file] = locate_config_value(:secret_file)
          bootstrap.config[:template_file] =  locate_config_value(:template_file)
          bootstrap.config[:bootstrap_template] =  locate_config_value(:bootstrap_template)
          bootstrap.config[:node_ssl_verify_mode] = locate_config_value(:node_ssl_verify_mode)
          bootstrap.config[:node_verify_api_cert] = locate_config_value(:node_verify_api_cert)
          bootstrap.config[:bootstrap_no_proxy] = locate_config_value(:bootstrap_no_proxy)
          bootstrap.config[:bootstrap_url] = locate_config_value(:bootstrap_url)
          bootstrap.config[:bootstrap_install_command] = locate_config_value(:bootstrap_install_command)
          bootstrap.config[:bootstrap_wget_options] = locate_config_value(:bootstrap_wget_options)
          bootstrap.config[:bootstrap_curl_options] = locate_config_value(:bootstrap_curl_options)
          bootstrap.config[:bootstrap_vault_file] = locate_config_value(:bootstrap_vault_file)
          bootstrap.config[:bootstrap_vault_json] = locate_config_value(:bootstrap_vault_json)
          bootstrap.config[:bootstrap_vault_item] = locate_config_value(:bootstrap_vault_item)
          bootstrap.config[:use_sudo_password] = locate_config_value(:use_sudo_password)
          bootstrap.config[:msi_url] = locate_config_value(:msi_url)
          bootstrap.config[:install_as_service] = locate_config_value(:install_as_service)
          bootstrap.config[:session_timeout] = locate_config_value(:session_timeout)
        end

      end
    end
  end
end
