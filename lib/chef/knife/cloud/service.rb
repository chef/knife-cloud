
require 'chef/knife/core/ui'

class Chef
  class Knife
    class Cloud
      class Service
        attr_accessor :connection, :cmd, :ui

        def initialize(app) # here app is the main cli object.
          @app = app
          @connection = new_connection()
          @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
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

        # factory method to create a command object
        def command_object(type)
          # derived classes must create a command object from concrete class.
          raise Chef::Exceptions::Override, "You must override create_command_object in #{self.to_s}"
          # example
          # case type
          # when 'server-create'
          #   ServerCreateCommand.new(@app)
          # when 'server-delete'
          #   ServerDeleteCommand.new(@app)
          # when 'server-list'
          #   ServerListCommand.new(@app)
          # when 'image-list'
          #   ImageListCommand.new(@app)
          # else
          #   raise "Unsupported command"
          # end
        end

        # cloud server commands
        def server_create
          create_dependencies
          # creates a create_command instance'
          @cmd = command_object('server-create')
          @cmd.run()
        end

        def server_delete
          # creates a delete_command instance
          @cmd = command_object('server-delete')
          @cmd.run()
        end

        def server_list
          # creates a server_list_command instance
          @cmd = command_object('server-list')
          @cmd.run()
        end

        def image_list
          # creates a image_list_command instance
          @cmd = command_object('image-list')
          @cmd.run()
        end

      end # class service
    end
  end
end