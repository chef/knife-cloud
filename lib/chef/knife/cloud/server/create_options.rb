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
              :short => "-I IMAGE_ID",
              :long => "--image IMAGE_ID",
              :description => "The image ID for the server",
              :proc => Proc.new { |i| Chef::Config[:knife][:image] = i }

            option :image_os_type,
              :short => "-T IMAGE_OS_TYPE",
              :long => "--image-os IMAGE_OS_TYPE",
              :description => "The image os type. options [windows/other]. Only required when cloud does not provide a way to identify image os, default is non-windows",
              :default => 'other',
              :proc => Proc.new { |i| Chef::Config[:knife][:image_os] = i }

            option :flavor,
              :short => "-f FLAVOR_ID",
              :long => "--flavor FLAVOR_ID",
              :description => "The flavor ID of server",
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
            
            option :delete_server_on_bootstrap_fail,
              :long => "--delete-server-on-bootstrap-fail",
              :boolean => true,
              :default => false,
              :description => "Destroy corresponding server if bootstrap fails"
          end
        end

      end # module end
    end
  end
end

