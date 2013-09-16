# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
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

require 'chef/knife/core/ui'
require 'chef/knife/cloud/chefbootstrap/ssh_bootstrap_protocol'
require 'chef/knife/cloud/chefbootstrap/winrm_bootstrap_protocol'
require 'chef/knife/cloud/chefbootstrap/windows_distribution'
require 'chef/knife/cloud/chefbootstrap/unix_distribution'
require 'chef/knife/cloud/exceptions'

class Chef
  class Knife
    class Cloud
      class Bootstrapper

        def initialize(config)
          @config = config
          @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
        end

        def bootstrap
          # uses BootstrapDistribution and BootstrapProtocol to perform bootstrap
          @protocol = create_bootstrap_protocol
          @distribution = create_bootstrap_distribution
          begin
            @protocol.send_bootstrap_command
          rescue Net::SSH::AuthenticationFailed => e
            error_message = "Authentication Failed during bootstrapping. #{e.message}."
            raise CloudExceptions::BootstrapError, error_message
          end
        end

        def create_bootstrap_protocol
          if @config[:bootstrap_protocol].nil? or @config[:bootstrap_protocol] == 'ssh'
            SshBootstrapProtocol.new(@config)
          elsif @config[:bootstrap_protocol] == 'winrm'
            WinrmBootstrapProtocol.new(@config)
          else
            # raise an exception, invalid bootstrap protocol.
            error_message = "Invalid bootstrap protocol."
            ui.fatal(error_message)
            raise CloudExceptions::BootstrapError, error_message
          end
        end

        def create_bootstrap_distribution
          if @config[:image_os_type] == 'windows'
            Chef::Knife::Cloud::WindowsDistribution.new(@config)
          elsif @config[:image_os_type] == 'linux'
            Chef::Knife::Cloud::UnixDistribution.new(@config)
          else
            # raise an exception, invalid bootstrap distribution.
            error_message = "Invalid bootstrap distribution. image_os_type should be either windows or linux."
            ui.fatal(error_message)
            raise CloudExceptions::BootstrapError, error_message
          end
        end
      end
    end
  end
end

