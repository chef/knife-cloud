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

class Chef
  class Knife
    class Cloud
      module ServerOptions
        def self.included(includer)
          includer.class_eval do
            option :chef_node_name,
              :short => "-N NAME",
              :long => "--node-name NAME",
              :description => "The name of the node and client to delete, if it differs from the server name. Only has meaning when used with the '--purge' option."

            option :custom_attributes,
              :long => "--custom-attributes CUSTOM_ATTRIBUTES",
              :description => "Custom attributes to be passed to Fog.",
              :proc => Proc.new {|args| Chef::Config[:knife][:custom_attributes] =  args.split(';').map{|keys| keys.split('=')}.map{|j| Hash[*j.map{|k| k.strip}]}}  
          end
        end
      end
    end
  end
end
