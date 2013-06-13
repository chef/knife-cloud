
require 'chef/knife/core/ui'
require 'chef/knife/cloud/command'

class Chef
  class Knife
    class Cloud
      class Service
        attr_accessor :connection, :cmd, :ui
        # Derived classes should set these as required to command classes.
        attr_reader :create_server_class, :list_servers_class, :delete_server_class, :list_image_class

        def initialize(app) # here app is the main cli object.
          @app = app
          @connection = new_connection()
          @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
          declare_command_classes
        end

        def declare_command_classes
          @create_server_class = @list_servers_class = @delete_server_class = @list_image_class = Command
        end

        def cloud_auth_params(options)
          # extract the provider specific auth options and return auth_params hash
          raise Chef::Exceptions::Override, "You must override cloud_auth_params in #{self.to_s}"
        end

        def new_connection()
          # @connection = Connection.new
          # Fog or cloud specific connection object must be created in derived.
        end

        def resource_allocation_list
          # TODO ??
        end

        def create_dependencies
          # Do nothing or override in cloud specific derived classes for pre-vm-creation setup steps
        end

        # cloud server commands
        def server_create
          create_dependencies
          # creates a create_command instance'
          @cmd = create_server_class.new(@app, self)
          @cmd.run()
        end

        def server_delete(server_name)
          # creates a delete_command instance
          @cmd = delete_server_class.new(@app, self)
          @cmd.run(server_name)
        end

        def server_list
          # creates a server_list_command instance
          @cmd = list_servers_class.new(@app, self)
          @cmd.run()
        end

        def image_list(image_filters)
          # creates a image_list_command instance
          @cmd = list_image_class.new(@app, self)
          @cmd.run(image_filters)
        end

      end # class service
    end
  end
end