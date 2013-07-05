#
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
#

require 'chef/knife/cloud/exceptions'


class Chef
  class Knife
    class Cloud
      class Service
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

        # Additional helpers
        def msg_pair(label, value, color=:cyan)
          if value && !value.to_s.empty?
            puts "#{ui.color(label, color)}: #{value}"
          end
        end

      end # class service
    end
  end
end