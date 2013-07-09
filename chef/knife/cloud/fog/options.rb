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
      module FogOptions

        def self.included(includer)
          includer.instance_eval do
            option :fog_version,
              :long => "--fog-version version",
              :description => "Fog gem version to use. Use the ruby gem version strings",
              :default => "",
              :proc => Proc.new { |v| Chef::Config[:knife][:cloud_fog_version] = v}
          end
        end

      end
    end
  end
end
