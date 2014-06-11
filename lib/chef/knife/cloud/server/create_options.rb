#
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

require 'chef/knife/cloud/chefbootstrap/bootstrap_options'
require 'chef/knife/cloud/server/options'

class Chef
  class Knife
    class Cloud
      module ServerCreateOptions

        def self.included(includer)
          includer.class_eval do
            include ServerOptions
            include BootstrapOptions
            option :image,
              :short => "-I IMAGE",
              :long => "--image IMAGE",
              :description => "A regexp matching an image name or an image ID for the server",
              :proc => Proc.new { |i| Chef::Config[:knife][:image] = i }

            option :image_os_type,
              :short => "-T IMAGE_OS_TYPE",
              :long => "--image-os-type IMAGE_OS_TYPE",
              :description => "The image os type. options [windows/linux]. Only required when cloud does not provide a way to identify image os",
              :default => "linux",
              :proc => Proc.new { |i| Chef::Config[:knife][:image_os_type] = i }

            option :flavor,
              :short => "-f FLAVOR_ID",
              :long => "--flavor FLAVOR_ID",
              :description => "The flavor name or ID of server",
              :proc => Proc.new { |f| Chef::Config[:knife][:flavor] = f }

            option :bootstrap_protocol,
              :long => "--bootstrap-protocol protocol",
              :description => "Protocol to bootstrap servers. options: winrm/ssh. For linux servers always use ssh.",
              :default => 'ssh',
              :proc => Proc.new { |b| Chef::Config[:knife][:bootstrap_protocol] = b}

            option :server_create_timeout,
              :long => "--server-create-timeout timeout",
              :description => "How long to wait until the server is ready; default is 600 seconds",
              :default => 600,
              :proc => Proc.new { |v| Chef::Config[:knife][:server_create_timeout] = v}
            
            option :delete_server_on_failure,
              :long => "--delete-server-on-failure",
              :boolean => true,
              :default => false,
              :description => "Destroy corresponding server in case of failure"

            option :chef_node_name_prefix,
              :long => "--chef-node-name-prefix PREFIX_FOR_NODE_NAME",
              :description => "The prefix for chef node name",
              :default => includer.snake_case_name.split('_').first,
              :proc => Proc.new { |key| Chef::Config[:knife][:chef_node_name_prefix] = key }

          end
        end

      end # module end
    end
  end
end

