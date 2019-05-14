#
# Copyright:: Copyright (c) 2013-2016 Chef Software, Inc.
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
require "chef/knife/cloud/command"
require "chef/knife/cloud/exceptions"
require "chef/knife/cloud/chefbootstrap/bootstrapper"

class Chef
  class Knife
    class Cloud
      class ServerCreateCommand < Command
        attr_accessor :server, :create_options
        Chef::Knife::Bootstrap.load_deps

        def initialize(argv = [])
          super argv
          # columns_with_info is array of hash with label, key and attribute extraction callback, ex [{:label => "Label text", :key => 'key', value_callback => callback_method to extract/format the required value}, ...]
          @columns_with_info = []
        end

        def validate_params!
          # set param vm_name to a random value if the name is not set by the user (plugin)
          config[:chef_node_name] = get_node_name(locate_config_value(:chef_node_name), locate_config_value(:chef_node_name_prefix))

          # validate connection_user, connection_password, ssh_identity_file for ssh bootstrap protocol and winrm_password for winrm bootstrap protocol
          errors = []
          if locate_config_value(:bootstrap_protocol) == "ssh"
            if locate_config_value(:ssh_identity_file).nil? && locate_config_value(:connection_password).nil?
              errors << "You must provide either Identity file or SSH Password."
            end
          elsif locate_config_value(:bootstrap_protocol) == "winrm"
            if locate_config_value(:winrm_password).nil?
              errors << "You must provide Winrm Password."
            end
          else
            errors << "You must provide a valid bootstrap protocol. options [ssh/winrm]. For linux type images, options [ssh]"
          end
          error_message = ""
          raise CloudExceptions::ValidationError, error_message if errors.each { |e| ui.error(e); error_message = "#{error_message} #{e}." }.any?
        end

        def before_exec_command
          post_connection_validations
          service.create_server_dependencies
        rescue CloudExceptions::ServerCreateDependenciesError => e
          ui.fatal(e.message)
          service.delete_server_dependencies
          raise e
        end

        def execute_command
          begin
            @server = service.create_server(create_options)
          rescue CloudExceptions::ServerCreateError => e
            ui.fatal(e.message)
            # server creation failed, so we need to rollback only dependencies.
            service.delete_server_dependencies
            raise e
          end
          service.server_summary(@server, @columns_with_info)
        end

        # Derived classes can override after_exec_command and also call cleanup_on_failure if any exception occured.
        def after_exec_command
            # bootstrap the server
          bootstrap
        rescue CloudExceptions::BootstrapError => e
          ui.fatal(e.message)
          cleanup_on_failure
          raise e
        rescue => e
          error_message = "Check if --bootstrap-protocol and --image-os-type is correct. #{e.message}"
          ui.fatal(error_message)
          cleanup_on_failure
          raise e, error_message
        end

        def cleanup_on_failure
          if config[:delete_server_on_failure]
            service.delete_server_dependencies
            service.delete_server_on_failure(@server)
          end
        end

        # Bootstrap the server
        def bootstrap
          before_bootstrap
          @bootstrapper = Bootstrapper.new(config)
          Chef::Log.debug("Bootstrapping the server...")
          ui.info("Bootstrapping the server by using #{ui.color("bootstrap_protocol", :cyan)}: #{config[:bootstrap_protocol]} and #{ui.color("image_os_type", :cyan)}: #{config[:image_os_type]}")
          @bootstrapper.bootstrap
          after_bootstrap
        end

        # any cloud specific initializations/cleanup we want to do around bootstrap.
        def before_bootstrap
        end

        def after_bootstrap
          service.server_summary(@server, @columns_with_info)
        end

        # knife-plugin can override set_default_config to set default config by using their own mechanism.
        def set_default_config
          config[:image_os_type] = "windows" if config[:bootstrap_protocol] == "winrm"
        end

        # generate a random name if chef_node_name is empty
        def get_node_name(chef_node_name, prefix)
          return chef_node_name unless chef_node_name.nil?
          # lazy uuids, 15 chars cause windows has limits
          ("#{prefix}-" + rand.to_s.split(".")[1]).slice(0, 14)
        end

        def post_connection_validations
        end

        private

      end # class ServerCreateCommand
    end
  end
end
