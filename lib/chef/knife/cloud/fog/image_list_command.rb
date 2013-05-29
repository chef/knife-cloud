
require 'fog'
require 'chef/knife/cloud/list_resource_command'

class Chef
  class Knife
    class Cloud
      class FogImageListCommand < ResourceListCommand

        def query_resource
          @service.connection.images.all
        end

      end # class FogImageListCommand
    end
  end
end