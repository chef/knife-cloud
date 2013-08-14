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
require 'chef/knife/bootstrap'

class Chef
  class Knife
    class Cloud
      class SshBootstrapProtocol < BootstrapProtocol
        attr_accessor :initial_sleep_delay

        def initialize(config)
          @bootstrap = (config[:image_os_type] == 'linux') ? Chef::Knife::Bootstrap.new : Chef::Knife::BootstrapWindowsSsh.new
          super
        end

        def init_bootstrap_options
          bootstrap.config[:ssh_user] = @config[:ssh_user]
          bootstrap.config[:ssh_password] = @config[:ssh_password]
          bootstrap.config[:ssh_port] = @config[:ssh_port]
          bootstrap.config[:identity_file] = @config[:identity_file]
          bootstrap.config[:host_key_verify] = @config[:host_key_verify]
          bootstrap.config[:use_sudo] = true unless @config[:ssh_user] == 'root'
          bootstrap.config[:template_file] =  @config[:template_file]
          super
        end

        def wait_for_server_ready
          print "\n#{ui.color("Waiting for sshd to host (#{@config[:bootstrap_ip_address]})", :magenta)}"
          print(".") until tcp_test_ssh(@config[:bootstrap_ip_address]) {
            sleep @initial_sleep_delay ||= 10
            puts("done")
          }
        end

        def tcp_test_ssh(hostname)
          tcp_socket = TCPSocket.new(hostname, 22)
          readable = IO.select([tcp_socket], nil, nil, 5)
          if readable
            Chef::Log.debug("sshd accepting connections on #{hostname}, banner is #{tcp_socket.gets}")
            yield
            true
          else
            false
          end
        rescue Errno::ETIMEDOUT
          false
        rescue Errno::EPERM
          false
        rescue Errno::ECONNREFUSED
          sleep 2
          false
        rescue Errno::EHOSTUNREACH, Errno::ENETUNREACH
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
