
require 'chef/knife/core/ui'
require 'chef/knife/cloud/exceptions'

class Chef
  class Knife

    class Cloud
      class Command
        attr_accessor :service, :ui

        def initialize(app, service) # here app is the main cli object.
          @app = app
          @service = service
          @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
        end

        def custom_arguments

        end

        def run(*params)
          # validate options required for server creation.
          validate!

          # Perform any steps before handling the command
          before_handler

          # exec the actual cmd
          exec_command(*params)

          # Perform any steps after handling the command
          after_handler
        end

        def exec_command(*params)
          raise Chef::Exceptions::Override, "You must override exec_command in #{self.to_s}"
        end

        # Derived classes can override before_handler and after_handler
        def before_handler
        end

        def after_handler
        end

        def validate!
          # validates necessary options/params to carry out the command.
          # subclasses to implement this.
        end

        # Helpers/utility method
        def msg_pair(label, value, color=:cyan)
          if value && !value.to_s.empty?
            puts "#{ui.color(label, color)}: #{value}"
          end
        end
        # Helpers/utility method
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
