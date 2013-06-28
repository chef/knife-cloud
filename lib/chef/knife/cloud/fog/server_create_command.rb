
require 'chef/knife/cloud/server/create_command'

class Chef
  class Knife
    class Cloud
      class FogServerCreateCommand < ServerCreateCommand

        def create
          begin
            @server = service.connection.servers.create(create_server_def)
          rescue Excon::Errors::BadRequest => e
            response = Chef::JSONCompat.from_json(e.response.body)
            if response['badRequest']['code'] == 400
              message = "Bad request (400): #{response['badRequest']['message']}"
              ui.fatal(message)
            else
              message = "Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}"
              ui.fatal(message)
            end
            raise CloudExceptions::ServerCreateError, message
          end

          msg_pair("Instance Name", @server.name)
          msg_pair("Instance ID", @server.id)

          print "\n#{ui.color("Waiting for server", :magenta)}"

          # wait for it to be ready to do stuff
          @server.wait_for(Integer(@app.locate_config_value(:server_create_timeout))) { print "."; ready? }

          puts("\n")
          @server
        end

        def create_server_def()
          # Force derived classes to define server def
          raise Chef::Exceptions::Override, "You must override create_server_def in #{self.to_s} to form server creation arguments."
        end

        def create_server_dependencies
          # This is cloud specific implementation, so let the cloud plugin override this.
          # if this method fails, it should raise CloudExceptions::ServerCreateDependenciesError
          # so as delete_server_dependencies is called.
        end

        def delete_server_dependencies
          # cleanup resources created before server creation. Called by framework.
          # This is cloud specific implementation, so let the cloud plugin override this.
        end

      end # class FogServerCreateCommand
    end
  end
end
