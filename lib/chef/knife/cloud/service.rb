#
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
#

require 'chef/knife/cloud/exceptions'
require "chef/knife/cloud/helpers"

class Chef
  class Knife
    class Cloud
      class Service
        include Cloud::Helpers
        attr_accessor :ui

        def initialize(options = {})
          @auth_params = options[:auth_params]
        end

        def connection
          # Fog or cloud specific connection object must be created in derived.
          raise Chef::Exceptions::Override, "You must override connection in #{self.to_s}"
        end

        # override in cloud specific derived classes
        def list_resource_allocations
        end

        # Do nothing or override in cloud specific derived classes for pre-vm-creation setup steps
        def create_server_dependencies
        end

        # Do nothing or override in cloud specific derived classes for pre-vm-creation setup steps
        def delete_server_dependencies
        end

        # cloud server specific implementation methods for commands.
        def create_server(options = {})
          raise Chef::Exceptions::Override, "You must override create_server in #{self.to_s}"
        end

        def delete_server(server_name)
          raise Chef::Exceptions::Override, "You must override delete_server in #{self.to_s}"
        end

        def list_servers
          raise Chef::Exceptions::Override, "You must override list_servers in #{self.to_s}"
        end

        def list_images(image_filters)
          raise Chef::Exceptions::Override, "You must override list_images in #{self.to_s}"
        end

      end # class service
    end
  end
end