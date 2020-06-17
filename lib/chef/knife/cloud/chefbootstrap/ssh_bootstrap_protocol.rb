# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
#
# Copyright:: Copyright (c) Chef Software Inc.
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

require_relative "bootstrap_protocol"
require "chef/knife/core/windows_bootstrap_context"
require "chef/knife/bootstrap"

class Chef
  class Knife
    class Cloud
      class SshBootstrapProtocol < BootstrapProtocol

        def initialize(config)
          @bootstrap = Chef::Knife::Bootstrap.new
          super
        end

        def init_bootstrap_options
          bootstrap.config[:connection_user] = config[:connection_user]
          bootstrap.config[:connection_password] = config[:connection_password]
          bootstrap.config[:connection_port] = config[:connection_port]
          bootstrap.config[:ssh_identity_file] = config[:ssh_identity_file]
          bootstrap.config[:ssh_verify_host_key] = config[:ssh_verify_host_key]
          bootstrap.config[:use_sudo] = true unless config[:connection_user] == "root"
          bootstrap.config[:ssh_gateway] = config[:ssh_gateway]
          bootstrap.config[:forward_agent] = config[:forward_agent]
          bootstrap.config[:use_sudo_password] = config[:use_sudo_password]
          super
        end

        def wait_for_server_ready
          print "\n#{ui.color("Waiting for sshd to host (#{config[:bootstrap_ip_address]})", :magenta)}"

          ssh_gateway = get_ssh_gateway_for(config[:bootstrap_ip_address])

          # The ssh_gateway & subnet_id are currently supported only in EC2.
          if ssh_gateway
            print(".") until tunnel_test_ssh(ssh_gateway, config[:bootstrap_ip_address]) do
              @initial_sleep_delay = !!config[:subnet_id] ? 40 : 10
              sleep @initial_sleep_delay
              puts("done")
            end
          else
            print(".") until tcp_test_ssh(config[:bootstrap_ip_address], config[:connection_port] || config[:ssh_port] ) do
              @initial_sleep_delay = !!config[:subnet_id] ? 40 : 10
              sleep @initial_sleep_delay
              puts("done")
            end
          end
        end

        def get_ssh_gateway_for(hostname)
          if config[:ssh_gateway]
            # The ssh_gateway specified in the knife config (if any) takes
            # precedence over anything in the SSH configuration
            Chef::Log.debug("Using ssh gateway #{config[:ssh_gateway]} from knife config")
            config[:ssh_gateway]
          else
            # Next, check if the SSH configuration has a ProxyCommand
            # directive for this host. If there is one, parse out the
            # host from the proxy command
            ssh_proxy = Net::SSH::Config.for(hostname)[:proxy]
            if ssh_proxy.respond_to?(:command_line_template)
              # ssh gateway_hostname nc %h %p
              proxy_pattern = /ssh\s+(\S+)\s+nc/
              matchdata = proxy_pattern.match(ssh_proxy.command_line_template)
              if matchdata.nil?
                Chef::Log.debug("Unable to determine ssh gateway for '#{hostname}' from ssh config template: #{ssh_proxy.command_line_template}")
                nil
              else
                # Return hostname extracted from command line template
                Chef::Log.debug("Using ssh gateway #{matchdata[1]} from ssh config")
                matchdata[1]
              end
            else
              # Return nil if we cannot find an ssh_gateway
              Chef::Log.debug("No ssh gateway found, making a direct connection")
              nil
            end
          end
        end

        def tcp_test_ssh(hostname, ssh_port)
          tcp_socket = TCPSocket.new(hostname, ssh_port)
          readable = IO.select([tcp_socket], nil, nil, 5)
          if readable
            ssh_banner = tcp_socket.gets
            if ssh_banner.nil? || ssh_banner.empty?
              false
            else
              Chef::Log.debug("ssh accepting connections on #{hostname}, banner is #{tcp_socket.gets}")
              yield
              true
            end
          else
            false
          end
        rescue Errno::EPERM, Errno::ETIMEDOUT
          Chef::Log.debug("ssh timed out: #{hostname}")
          false
        rescue SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH, IOError
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

        def tunnel_test_ssh(ssh_gateway, hostname, &block)
          status = false
          gateway = configure_ssh_gateway(ssh_gateway)
          remote_ssh_port = config[:connection_port] || config[:ssh_port] || 22
          gateway.open(hostname, remote_ssh_port) do |local_tunnel_port|
            status = tcp_test_ssh("localhost", local_tunnel_port, &block)
          end
          status
        rescue SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH, IOError
          sleep 2
          false
        rescue Errno::EPERM, Errno::ETIMEDOUT
          false
        end

        def configure_ssh_gateway(ssh_gateway)
          gw_host, gw_user = ssh_gateway.split("@").reverse
          gw_host, gw_port = gw_host.split(":")
          gateway_options = { port: gw_port || 22 }

          # Load the SSH config for the SSH gateway host.
          # Set the gateway user if it was not part of the
          # SSH gateway string, and use any configured
          # SSH keys.
          ssh_gateway_config = Net::SSH::Config.for(gw_host)
          gw_user ||= ssh_gateway_config[:user]

          # Always use the gateway keys from the SSH Config
          gateway_keys = ssh_gateway_config[:keys]

          # Use the keys specificed on the command line if available (overrides SSH Config)
          if config[:ssh_gateway_identity]
            gateway_keys = Array(config[:ssh_gateway_identity])
          end

          unless gateway_keys.nil?
            gateway_options[:keys] = gateway_keys
          end

          Net::SSH::Gateway.new(gw_host, gw_user, gateway_options)
        end
      end
    end
  end
end
