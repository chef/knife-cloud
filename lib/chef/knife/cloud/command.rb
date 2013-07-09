#
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
#
require 'chef/knife'
require "chef/knife/cloud/helpers"

class Chef
  class Knife

    class Cloud
      class Command < Chef::Knife
        include Cloud::Helpers
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

        def validate!(*keys)
          # validates necessary options/params to carry out the command.
          # subclasses to implement this.
          errors = []
          keys.each do |k|
            errors << "You did not provided a valid '#{pretty_key(k)}' value." if config[k].nil?
          end
          exit 1 if errors.each{|e| ui.error(e)}.any?
        end

        #generate a random name if chef_node_name is empty
        def get_node_name(chef_node_name)
          return chef_node_name unless chef_node_name.nil?
          #lazy uuids
          chef_node_name = "os-"+rand.to_s.split('.')[1]
        end

        def pretty_key(key)
          key.to_s.gsub(/_/, ' ').gsub(/\w+/){ |w| (w =~ /(ssh)|(aws)/i) ? w.upcase  : w.capitalize }
        end

      end # class Command
    end
  end
end
