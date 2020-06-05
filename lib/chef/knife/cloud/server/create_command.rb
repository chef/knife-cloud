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
require_relative "../command_bootstrap"
require_relative "../exceptions"
require_relative "../chefbootstrap/bootstrapper"

class Chef
  class Knife
    class Cloud
      class ServerCreateCommand < BootstrapCommand
        attr_accessor :server, :create_options
        Chef::Knife::Bootstrap.load_deps

        def initialize(argv = [])
          super argv
          # columns_with_info is array of hash with label, key and attribute extraction callback, ex [{:label => "Label text", :key => 'key', value_callback => callback_method to extract/format the required value}, ...]
          @columns_with_info = []
        end

        def validate_params!
          # set param vm_name to a random value if the name is not set by the user (plugin)
          config[:chef_node_name] = get_node_name(config[:chef_node_name], config[:chef_node_name_prefix])

          # validate ssh_identity_file for connection protocol and connection_user, connection_password for both ssh bootstrap protocol and winrm bootstrap protocol
          errors = []
          if config[:connection_protocol] == "ssh"
            if config[:ssh_identity_file].nil? && config[:connection_password].nil?
              errors << "You must provide either SSH Identity file or Connection Password."
            end
          elsif config[:connection_protocol] == "winrm"
            if config[:connection_password].nil?
              errors << "You must provide Connection Password."
            end
          else
            errors << "You must provide a valid connection protocol. options [ssh/winrm]. For linux type images, options [ssh]"
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
          error_message = "Check if --connection-protocol and --image-os-type is correct. #{e.message}"
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
          ui.info("Bootstrapping the server by using #{ui.color("connection_protocol", :cyan)}: #{config[:connection_protocol]} and #{ui.color("image_os_type", :cyan)}: #{config[:image_os_type]}")
          @bootstrapper.bootstrap
          after_bootstrap
        end

        # any cloud specific initializations/cleanup we want to do around bootstrap.
        def before_bootstrap; end

        def after_bootstrap
          service.server_summary(@server, @columns_with_info)
        end

        # knife-plugin can override set_default_config to set default config by using their own mechanism.
        def set_default_config
          config[:image_os_type] = "windows" if config[:connection_protocol] == "winrm"
        end

        # generate a random name if chef_node_name is empty
        def get_node_name(chef_node_name, prefix)
          return chef_node_name unless chef_node_name.nil?

          # lazy uuids, 15 chars cause windows has limits
          ("#{prefix}-" + rand.to_s.split(".")[1]).slice(0, 14)
        end

        def post_connection_validations; end
      end # class ServerCreateCommand
    end
  end
end
