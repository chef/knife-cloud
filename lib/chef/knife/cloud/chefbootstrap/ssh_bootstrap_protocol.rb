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
require 'chef/knife/core/windows_bootstrap_context'
require 'chef/knife/bootstrap'


class Chef
  class Knife
    class Cloud
      class SshBootstrapProtocol < BootstrapProtocol

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
          bootstrap.config[:ssh_gateway] = locate_config_value(:ssh_gateway)
          bootstrap.config[:forward_agent] = locate_config_value(:forward_agent)
          bootstrap.config[:use_sudo_password] = locate_config_value(:use_sudo_password)
          super
        end

        def wait_for_server_ready
          print "\n#{ui.color("Waiting for sshd to host (#{@config[:bootstrap_ip_address]})", :magenta)}"

          # The ssh_gateway & subnet_id are currently supported only in EC2.
          if config[:ssh_gateway]
            print(".") until tunnel_test_ssh(@config[:bootstrap_ip_address]) {
              @initial_sleep_delay = !!locate_config_value(:subnet_id) ? 40 : 10
              sleep @initial_sleep_delay
              puts("done")
            }
          else
            print(".") until tcp_test_ssh(@config[:bootstrap_ip_address]) {
              @initial_sleep_delay = !!locate_config_value(:subnet_id) ? 40 : 10
              sleep @initial_sleep_delay
              puts("done")
            }
          end
        end

        def tcp_test_ssh(hostname)
          tcp_socket = TCPSocket.new(hostname, 22)
          readable = IO.select([tcp_socket], nil, nil, 5)
          if readable
            ssh_banner = tcp_socket.gets
            if ssh_banner.nil? or ssh_banner.empty?
              false
            else
              Chef::Log.debug("ssh accepting connections on #{hostname}, banner is #{tcp_socket.gets}")
              yield
              true
            end
          else
            false
          end
          rescue Errno::ETIMEDOUT
            Chef::Log.debug("ssh timed out: #{hostname}")
            false
          rescue Errno::EPERM
            Chef::Log.debug("ssh timed out: #{hostname}")
            false
          rescue Errno::ECONNREFUSED
            Chef::Log.debug("ssh failed to connect: #{hostname}")
            sleep 2
            false
          rescue Errno::EHOSTUNREACH, Errno::ENETUNREACH
            Chef::Log.debug("ssh failed to connect: #{hostname}")
            sleep 2
            false
          rescue Errno::ENETUNREACH
            Chef::Log.debug("ssh failed to connect: #{hostname}")
            sleep 2
            false
           # This happens on some mobile phone networks
          rescue Errno::ECONNRESET
             Chef::Log.debug("ssh reset its connection: #{hostname}")
            sleep 2
            false
          ensure
            tcp_socket && tcp_socket.close
          end
        end

        def tunnel_test_ssh(hostname, &block)
          gw_host, gw_user = @config[:ssh_gateway].split('@').reverse
          gw_host, gw_port = gw_host.split(':')
          gateway = Net::SSH::Gateway.new(gw_host, gw_user, :port => gw_port || 22)
          status = false
          gateway.open(hostname, config[:ssh_port]) do |local_tunnel_port|
            status = tcp_test_ssh('localhost', local_tunnel_port, &block)
          end
          status
          rescue SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH, IOError
            sleep 2
            false
          rescue Errno::EPERM, Errno::ETIMEDOUT
            false
        end

    end
  end
end
