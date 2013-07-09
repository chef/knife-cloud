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

require 'chef/knife/cloud/server/options'

class Chef
  class Knife
    class Cloud
      module ServerDeleteOptions
        def self.included(includer)
          includer.class_eval do
            include ServerOptions

            option :purge,
              :short => "-P",
              :long => "--purge",
              :boolean => true,
              :default => false,
              :description => "Destroy corresponding node and client on the Chef Server, in addition to destroying the Cloud node itself. Assumes node and client have the same name as the server (if not, add the '--node-name' option)."

          end
        end
      end
    end
  end
end

