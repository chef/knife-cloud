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

require 'chef/knife/cloud/chefbootstrap/bootstrap_protocol'

class Chef
  class Knife
    class Cloud
      class WinrmBootstrapProtocol < BootstrapProtocol

        def initialize(config)
          load_winrm_deps
          @bootstrap = Chef::Knife::BootstrapWindowsWinrm.new
          super
        end

        def load_winrm_deps
          require 'winrm'
          require 'chef/knife/bootstrap_windows_winrm'
          require 'chef/knife/core/windows_bootstrap_context'
          require 'chef/knife/winrm'
        end

        def init_bootstrap_options
          bootstrap.config[:winrm_user] = @config[:winrm_user] || 'Administrator'
          bootstrap.config[:winrm_password] = @config[:winrm_password]
          bootstrap.config[:winrm_transport] = @config[:winrm_transport]
          bootstrap.config[:winrm_port] = @config[:winrm_port]
          bootstrap.config[:auth_timeout] =  @config[:auth_timeout]
          bootstrap.config[:winrm_ssl_verify_mode] = @config[:winrm_ssl_verify_mode]
          super
        end

        def wait_for_server_ready
          print "\n#{ui.color("Waiting for winrm to host (#{@config[:bootstrap_ip_address]})", :magenta)}"
          print(".") until tcp_test_winrm(@config[:bootstrap_ip_address], @config[:winrm_port]){
            sleep @initial_sleep_delay ||= 10
            puts("done")
          }
        end

        def tcp_test_winrm(hostname, port)
          tcp_socket = TCPSocket.new(hostname, port)
          return true
        rescue SocketError
          sleep 2
          false
        rescue Errno::ETIMEDOUT
          false
        rescue Errno::EPERM
          false
        rescue Errno::ECONNREFUSED
          sleep 2
          false
        rescue Errno::EHOSTUNREACH
          sleep 2
          false
        rescue Errno::ENETUNREACH
          sleep 2
          false
        ensure
          tcp_socket && tcp_socket.close
        end

      end
    end
  end
end

