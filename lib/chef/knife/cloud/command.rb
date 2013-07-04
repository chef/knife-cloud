#
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
#

require 'chef/knife'

class Chef
  class Knife

    class Cloud
      class Command < Chef::Knife
        attr_accessor :service, :custom_arguments

        def run
          # validate command pre-requisites (cli options)
          validate!

          # setup the service
          @service = create_service_instance

          service.ui = ui # for interactive user prompts/messages

          # Perform any steps before handling the command
          before_exec_command

          # exec the actual cmd
          execute_command

          # Perform any steps after handling the command
          after_exec_command
        end

        def create_service_instance
          raise Chef::Exceptions::Override, "You must override create_service_instance in #{self.to_s} to create cloud specific service"
        end

        def execute_command
          raise Chef::Exceptions::Override, "You must override execute_command in #{self.to_s}"
        end

        # Derived classes can override before_exec_command and after_exec_command
        def before_exec_command
        end

        def after_exec_command
        end

        def validate!
          # validates necessary options/params to carry out the command.
          # subclasses to implement this.
        end

        def locate_config_value(key)
          key = key.to_sym
          Chef::Config[:knife][key] || config[key]
        end

        #generate a random name if chef_node_name is empty
        def get_node_name(chef_node_name)
          return chef_node_name unless chef_node_name.nil?
          #lazy uuids
          chef_node_name = "os-"+rand.to_s.split('.')[1]
        end

      end # class Command
    end
  end
end
