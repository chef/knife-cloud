
require 'chef/knife/cloud/chefbootstrap/bootstrap_protocol'
require 'chef/knife/bootstrap'
class Chef
  class Knife
    class Cloud
      class SshBootstrapProtocol < BootstrapProtocol
        attr_accessor :initial_sleep_delay

        def initialize(app)
          @bootstrap = (app[:image_os_type] == 'other') ? Chef::Knife::Bootstrap.new : Chef::Knife::BootstrapWindowsSsh.new
          super
        end

        def init_bootstrap_options
          bootstrap.config[:ssh_user] = @app[:ssh_user]
          bootstrap.config[:identity_file] = @app[:identity_file]
          bootstrap.config[:host_key_verify] = @app[:host_key_verify]
          bootstrap.config[:use_sudo] = true unless @app[:ssh_user] == 'root'
          super
        end

        def wait_for_server_ready
          print "\n#{ui.color("Waiting for sshd to host (#{@app[:bootstrap_ip_address]})", :magenta)}"
          print(".") until tcp_test_ssh(@app[:bootstrap_ip_address]) {
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
