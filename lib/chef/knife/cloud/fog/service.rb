
require 'chef/knife/cloud/service'
require 'chef/knife/cloud/fog/server_create_command'
require 'chef/knife/cloud/fog/server_list_command'
require 'chef/knife/cloud/fog/server_delete_command'


class Chef
  class Knife
    class Cloud
      class FogService < Service
        attr_accessor :fog_version

        def new_connection(auth_params={})
          @connection ||= begin
              connection = Fog::Compute.new(cloud_auth_params(@app.config))
                          rescue Excon::Errors::Unauthorized => e
                            ui.fatal("Connection failure, please check your username and password.")
                            exit 1
                          rescue Excon::Errors::SocketError => e
                            ui.fatal("Connection failure, please check your authentication URL.")
                            exit 1
                          end
        end

        # factory method to create a command object
        def command_object(type)
          case type
          when 'server-create'
            Cloud::FogServerCreateCommand.new(@app, self)
          when 'server-delete'
            Cloud::FogServerDeleteCommand.new(@app, self)
          when 'server-list'
            Cloud::FogServerListCommand.new(@app, self)
          when 'image-list'
            Cloud::FogImageListCommand.new(@app, self)
          else
            raise "Unsupported command"
          end
        end

      end
    end
  end
end