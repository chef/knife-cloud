# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
#
# Copyright:: Copyright (c) Chef Software Inc.
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

require "chef/knife/core/ui"
require_relative "../helpers"

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
          raise Chef::Exceptions::Override, "You must override wait_for_server_ready in #{self}"
        end

        def send_bootstrap_command
          wait_for_server_ready
          init_bootstrap_options
          @bootstrap.run
        end

        def init_bootstrap_options
          # set the command bootstrap options.
          bootstrap.name_args << config[:bootstrap_ip_address]
          bootstrap.config[:chef_node_name] = config[:chef_node_name]
          bootstrap.config[:run_list] = config[:run_list]
          bootstrap.config[:prerelease] = config[:prerelease]
          bootstrap.config[:bootstrap_version] = config[:bootstrap_version]
          bootstrap.config[:bootstrap_proxy] = config[:bootstrap_proxy]
          bootstrap.config[:environment] = config[:environment]
          # see chef/knife/bootstrap.rb #warn_chef_config_secret_key.
          bootstrap.config[:encrypted_data_bag_secret] = config[:encrypted_data_bag_secret]
          bootstrap.config[:encrypted_data_bag_secret_file] = config[:encrypted_data_bag_secret_file]
          bootstrap.config[:first_boot_attributes] = config[:first_boot_attributes]
          bootstrap.config[:secret] = config[:secret]
          bootstrap.config[:secret_file] = config[:secret_file]
          bootstrap.config[:bootstrap_template] = config[:bootstrap_template]
          bootstrap.config[:node_ssl_verify_mode] = config[:node_ssl_verify_mode]
          bootstrap.config[:node_verify_api_cert] = config[:node_verify_api_cert]
          bootstrap.config[:bootstrap_no_proxy] = config[:bootstrap_no_proxy]
          bootstrap.config[:bootstrap_url] = config[:bootstrap_url]
          bootstrap.config[:bootstrap_install_command] = config[:bootstrap_install_command]
          bootstrap.config[:bootstrap_wget_options] = config[:bootstrap_wget_options]
          bootstrap.config[:bootstrap_curl_options] = config[:bootstrap_curl_options]
          bootstrap.config[:bootstrap_vault_file] = config[:bootstrap_vault_file]
          bootstrap.config[:bootstrap_vault_json] = config[:bootstrap_vault_json]
          bootstrap.config[:bootstrap_vault_item] = config[:bootstrap_vault_item]
          bootstrap.config[:use_sudo_password] = config[:use_sudo_password]
          bootstrap.config[:msi_url] = config[:msi_url]
          bootstrap.config[:install_as_service] = config[:install_as_service]
          bootstrap.config[:session_timeout] = config[:session_timeout]
          bootstrap.config[:channel] = config[:channel]
          bootstrap.config[:bootstrap_product] = config[:bootstrap_product]
        end

      end
    end
  end
end
