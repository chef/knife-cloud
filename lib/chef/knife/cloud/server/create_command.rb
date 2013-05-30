
require 'chef/knife/cloud/command'
require 'chef/knife/cloud/chefbootstrap/bootstrapper'

class Chef
  class Knife
    class Cloud
      class ServerCreateCommand < Command
        attr_accessor :server

        def exec_command(*params)
          begin
            create_server_dependencies
            # actually create the server
            @server = create

            # bootstrap the server
            bootstrap
          rescue CloudExceptions::ServerCreateDependenciesError => e
            ui.fatal(e.message)
            delete_server_dependencies # rollback any resources that were created.
            raise e
          rescue CloudExceptions::ServerCreateError => e
            ui.fatal(e.message)
            # server creation failed, so we need to rollback only dependencies.
            delete_server_dependencies
            raise e
          end

          #TODO -KD- Should we really rollback all (delete_server) on bootstrap failure? may be cli option for user to decide. default dont rollback?
        end

        def create
          raise Chef::Exceptions::Override, "You must override create in #{self.to_s} for server creation."
        end

        def create_server_dependencies
          raise Chef::Exceptions::Override, "You must override create_server_dependencies in #{self.to_s} to create dependencies required for server creation."
        end

        def delete_server_dependencies
          # cleanup resources created before server creation.
          raise Chef::Exceptions::Override, "You must override delete_server_dependencies in #{self.to_s} to remove dependencies created before server creation."
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