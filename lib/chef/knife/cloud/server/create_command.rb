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
require 'chef/knife/cloud/command'
require 'chef/knife/cloud/exceptions'
require 'chef/knife/cloud/chefbootstrap/bootstrapper'

class Chef
  class Knife
    class Cloud
      class ServerCreateCommand < Command
        attr_accessor :server, :create_options

        def initialize(argv=[])
          super argv
          # columns_with_info is array of hash with label, key and attribute extraction callback, ex [{:label => "Label text", :key => 'key', value_callback => callback_method to extract/format the required value}, ...]
          @columns_with_info = []
        end

        def validate_params!
          # set param vm_name to a random value if the name is not set by the user (plugin)
          config[:chef_node_name] = get_node_name(locate_config_value(:chef_node_name), locate_config_value(:chef_node_name_prefix))

          # validate ssh_user, ssh_password, identity_file for ssh bootstrap protocol and winrm_password for winrm bootstrap protocol
          errors = []

          if locate_config_value(:bootstrap_protocol) == 'ssh'
            if locate_config_value(:identity_file).nil? && locate_config_value(:ssh_password).nil?
              errors << "You must provide either Identity file or SSH Password."
            end
          elsif locate_config_value(:bootstrap_protocol) == 'winrm'
            if locate_config_value(:winrm_password).nil?
              errors << "You must provide Winrm Password."
            end
          else
            errors << "You must provide a valid bootstrap protocol. options [ssh/winrm]. For linux type images, options [ssh]"
          end
          error_message = ""
          raise CloudExceptions::ValidationError, error_message if errors.each{|e| ui.error(e); error_message = "#{error_message} #{e}."}.any?
        end

        def before_exec_command
          begin
            post_connection_validations
            service.create_server_dependencies
          rescue CloudExceptions::ServerCreateDependenciesError => e
            ui.fatal(e.message)
            service.delete_server_dependencies
            raise e
          end
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
          begin
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
          ssh_override_winrm if locate_config_value(:bootstrap_protocol) == 'ssh'
        end

        def after_bootstrap
          service.server_summary(@server, @columns_with_info)
        end

        # knife-plugin can override set_default_config to set default config by using their own mechanism.
        def set_default_config
          config[:image_os_type] = 'windows' if config[:bootstrap_protocol] == 'winrm'
        end

        #generate a random name if chef_node_name is empty
        def get_node_name(chef_node_name, prefix)
          return chef_node_name unless chef_node_name.nil?
          #lazy uuids, 15 chars cause windows has limits
          chef_node_name = ("#{prefix}-"+rand.to_s.split('.')[1]).slice(0,14)
        end

        def post_connection_validations
        end

        private

        # Here, ssh config override winrm config
        def ssh_override_winrm
          # unchanged ssh_user and changed winrm_user, override ssh_user
          if locate_config_value(:ssh_user).eql?(options[:ssh_user][:default]) &&
              !locate_config_value(:winrm_user).eql?(options[:winrm_user][:default])
            config[:ssh_user] = locate_config_value(:winrm_user)
          end
          # unchanged ssh_port and changed winrm_port, override ssh_port
          if locate_config_value(:ssh_port).eql?(options[:ssh_port][:default]) &&
              !locate_config_value(:winrm_port).eql?(options[:winrm_port][:default])
            config[:ssh_port] = locate_config_value(:winrm_port)
          end
          # unset ssh_password and set winrm_password, override ssh_password
          if locate_config_value(:ssh_password).nil? &&
              !locate_config_value(:winrm_password).nil?
            config[:ssh_password] = locate_config_value(:winrm_password)
          end
          # unset identity_file and set kerberos_keytab_file, override identity_file
          if locate_config_value(:identity_file).nil? &&
              !locate_config_value(:kerberos_keytab_file).nil?
            config[:identity_file] = locate_config_value(:kerberos_keytab_file)
          end          
        end
      end # class ServerCreateCommand
    end
  end
end

