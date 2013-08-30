#
# Author:: Siddheshwar More (<siddheshwar.more@clogeny.com>)
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

class Chef
  class Knife
    class Cloud
      module ServerListOptions
        def self.included(includer)
          includer.class_eval do

            option :chef_data,
              :long => "--chef-data",
              :boolean => true,
              :default => false,
              :description => "Display chef node data which include chef node name, environment name, fqdn, platform, runlist and tags."

            option :chef_node_attribute,
              :long => "--chef-node-attribute CHEF_NODE_ATTRIBUTE_NAME",
              :description => "Used with --chef-data option. It display node attributes details by adding new column in server list display.",
              :proc => Proc.new { |i| Chef::Config[:knife][:chef_node_attribute] = i }
              
          end
        end
      end
    end
  end
end

