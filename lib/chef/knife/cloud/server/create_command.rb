
require 'chef/knife/cloud/command'
require 'chef/knife/cloud/exceptions'
require 'chef/knife/cloud/chefbootstrap/bootstrapper'

class Chef
  class Knife
    class Cloud
      class ServerCreateCommand < Command
        attr_accessor :server, :create_options

        def before_exec_command
          begin
            service.create_server_dependencies
          rescue CloudExceptions::ServerCreateDependenciesError => e
            ui.fatal(e.message)
            service.delete_server_dependencies # rollback any resources that were created.
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
        end

        def after_exec_command
          begin
            # bootstrap the server
            bootstrap
          rescue CloudExceptions::BootstrapError => e
            #TODO -KD- Should we really rollback all (delete_server) on bootstrap failure? may be cli option for user to decide. default dont rollback?
          end
        end


        # Bootstrap the server
        def bootstrap
          before_bootstrap
          @bootstrapper = Bootstrapper.new(config)
          Chef::Log.debug("Bootstrapping the server...")
          @bootstrapper.bootstrap
          after_bootstrap
        end

        # any cloud specific initializations/cleanup we want to do around bootstrap.
        def before_bootstrap
        end
        def after_bootstrap
        end

      end # class ServerCreateCommand
    end
  end
end
