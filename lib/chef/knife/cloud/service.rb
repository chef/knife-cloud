#
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
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

        def delete_server_on_failure(server = nil)
          raise Chef::Exceptions::Override, "You must override delete_server_on_failure in #{self.to_s} to delete server"
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

        def list_resource_configurations
          raise Chef::Exceptions::Override, "You must override list_resource_configurations in #{self.to_s}"
        end

        def get_server(server_name)
          raise Chef::Exceptions::Override, "You must override get_server in #{self.to_s}"
        end

        def server_summary(server, columns_with_info = [])
          raise Chef::Exceptions::Override, "You must override server_summary in #{self.to_s}"
        end

        def add_custom_attributes(server_def)
          Chef::Config[:knife][:custom_attributes].map{|args| args.map{|k,v| server_def.merge!(k.to_sym => v)}} unless Chef::Config[:knife][:custom_attributes].nil?
        end

      end # class service
    end
  end
end

