# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
#
# Copyright:: Copyright (c) 2013-2016 Chef Software, Inc.
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

require "chef/knife/core/bootstrap_context"
require "net/ssh/multi"

class Chef
  class Knife
    class Cloud
      # Ideally chef/knife/bootstap should expose this as module.
      module BootstrapOptions

        def self.included(includer)
          includer.class_eval do

            deps do
              require "chef/json_compat"
              require "tempfile" unless defined?(Tempfile)
              require "net/ssh" unless defined?(Net::SSH)
              require "chef/knife/ssh"
              Chef::Knife::Ssh.load_deps
            end

          end
        end
      end # module ends
    end
  end
end
