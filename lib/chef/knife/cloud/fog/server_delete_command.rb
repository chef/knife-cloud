
require 'chef/json_compat'
require 'chef/knife/cloud/server/delete_command'

class Chef
  class Knife
    class Cloud
      class FogServerDeleteCommand < ServerDeleteCommand

        def exec_command(*params)

          # find the server to be deleted.
          begin
            @server_name = params[0]

            @server = @service.connection.servers.get(server_name)

            msg_pair("Instance Name", server.name)
            msg_pair("Instance ID", server.id)

            puts "\n"
            ui.confirm("Do you really want to delete this server")

            # delete the server
            server.destroy
          rescue NoMethodError
            ui.error("Could not locate server '#{server_name}'.")
            raise "Could not locate server '#{server_name}'."
          rescue Excon::Errors::BadRequest => e
            response = Chef::JSONCompat.from_json(e.response.body)
            ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
            raise e
          end
        end

      end
    end
  end
end