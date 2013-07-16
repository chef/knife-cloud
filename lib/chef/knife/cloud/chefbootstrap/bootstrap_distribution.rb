#
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
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
require 'chef/knife/bootstrap_windows_base'
require 'chef/knife/cloud/chefbootstrap/bootstrap_distribution'
require 'chef/knife/cloud/helpers'
class Chef
  class Knife
    class Cloud
      class BootstrapDistribution
        include Chef::Knife::TemplateFinder # This is included to expose get_template method from windows distribution.
        include Chef::Knife::Cloud::Helpers
        attr_accessor :template
        attr_reader :config
        def initialize(config)
        end
      end
    end
  end
end
