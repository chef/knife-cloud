
require 'chef/knife/cloud/service'
require 'chef/knife/cloud/fog/server_create_command'
require 'chef/knife/cloud/fog/server_list_command'
require 'chef/knife/cloud/fog/server_delete_command'


class Chef
  class Knife
    class Cloud
      class FogService < Service
        attr_accessor :fog_version

        def initialize(app) # here app is the main cli object.
          @fog_version = app.config[:fog_version]
          # Load specific version of fog. Any other classes/modules using fog are loaded after this.
          gem "fog", Chef::Config[:knife][:cloud_fog_version]
          require 'fog'
          Chef::Log.debug("Using fog version: #{Gem.loaded_specs["fog"].version}")
          super
        end

        def declare_command_classes
          super
          # override the classes
          @create_server_class = Cloud::FogServerCreateCommand
          @list_servers_class = Cloud::FogServerListCommand
          @delete_server_class = Cloud::FogServerDeleteCommand
          @list_image_class = Cloud::FogImageListCommand
        end

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

      end
    end
  end
end