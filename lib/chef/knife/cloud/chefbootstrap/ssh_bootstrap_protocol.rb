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
          bootstrap.config[:ssh_port] = locate_config_value(:ssh_port)
          bootstrap.config[:identity_file] = @config[:identity_file]
          bootstrap.config[:host_key_verify] = @config[:host_key_verify]
          bootstrap.config[:use_sudo] = true unless @config[:ssh_user] == 'root'
          bootstrap.config[:template_file] =  @config[:template_file]
          bootstrap.config[:ssh_gateway] = locate_config_value(:ssh_gateway)
          bootstrap.config[:forward_agent] = locate_config_value(:forward_agent)
          bootstrap.config[:use_sudo_password] = locate_config_value(:use_sudo_password)
          super
        end

        def wait_for_server_ready
          print "\n#{ui.color("Waiting for sshd to host (#{@config[:bootstrap_ip_address]})", :magenta)}"

          ssh_gateway = get_ssh_gateway_for(@config[:bootstrap_ip_address])

          # The ssh_gateway & subnet_id are currently supported only in EC2.
          if ssh_gateway
            print(".") until tunnel_test_ssh(ssh_gateway, @config[:bootstrap_ip_address]) {
              @initial_sleep_delay = !!locate_config_value(:subnet_id) ? 40 : 10
              sleep @initial_sleep_delay
              puts("done")
            }
          else
            print(".") until tcp_test_ssh(@config[:bootstrap_ip_address], locate_config_value(:ssh_port)) {
              @initial_sleep_delay = !!locate_config_value(:subnet_id) ? 40 : 10
              sleep @initial_sleep_delay
              puts("done")
            }
          end
        end

        def get_ssh_gateway_for(hostname)
          if locate_config_value(:ssh_gateway)
            # The ssh_gateway specified in the knife config (if any) takes
            # precedence over anything in the SSH configuration
            Chef::Log.debug("Using ssh gateway #{locate_config_value(:ssh_gateway)} from knife config")
            locate_config_value(:ssh_gateway)
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
          begin
            tcp_socket = TCPSocket.new(hostname, ssh_port)
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
        end

        def tunnel_test_ssh(ssh_gateway, hostname, &block)
          begin
            status = false
            gateway = configure_ssh_gateway(ssh_gateway)
            gateway.open(hostname, locate_config_value(:ssh_port)) do |local_tunnel_port|
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

        def configure_ssh_gateway(ssh_gateway)
          gw_host, gw_user = ssh_gateway.split('@').reverse
          gw_host, gw_port = gw_host.split(':')
          gateway_options = { :port => gw_port || 22 }

          # Load the SSH config for the SSH gateway host.
          # Set the gateway user if it was not part of the
          # SSH gateway string, and use any configured
          # SSH keys.
          ssh_gateway_config = Net::SSH::Config.for(gw_host)
          gw_user ||= ssh_gateway_config[:user]

          # Always use the gateway keys from the SSH Config
          gateway_keys = ssh_gateway_config[:keys]        

          # Use the keys specificed on the command line if available (overrides SSH Config)
          if locate_config_value(:ssh_gateway_identity)
            gateway_keys = Array(locate_config_value(:ssh_gateway_identity))
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
