
require 'chef/knife/cloud/command'
require 'chef/knife/cloud/chefbootstrap/bootstrapper'

class Chef
  class Knife
    class Cloud
      class ServerCreateCommand < Command
        attr_accessor :server

        def exec_command
          create_dependencies
          # actually create the server
          @server = create

          # bootstrap the server
          bootstrap

          #TODO -KD- Failure handling
        end

        def create
          raise Chef::Exceptions::Override, "You must override create in #{self.to_s} for server creation."
        end

        def create_dependencies
          raise Chef::Exceptions::Override, "You must override create_dependencies in #{self.to_s} to create dependencies required for server creation."
        end

        def cleanup_resources_on_failure
          # cleanup resources created before server creation.
          raise Chef::Exceptions::Override, "You must override cleanup_resources_on_failure in #{self.to_s} to remove dependencies created before server creation."
        end

        # Bootstrap the server
        def bootstrap
          before_bootstrap
          @bootstrapper = Bootstrapper.new(@app)
          puts "Bootstrapping the server..."
          @bootstrapper.bootstrap
          after_bootstrap
        end

        # any initializations/cleanup we want to do around bootstrap.
        def before_bootstrap
        end
        def after_bootstrap
        end

      end # class ServerCreateCommand
    end
  end
end