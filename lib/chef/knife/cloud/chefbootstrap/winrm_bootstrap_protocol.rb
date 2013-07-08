
require 'chef/knife/cloud/chefbootstrap/bootstrap_protocol'

class Chef
  class Knife
    class Cloud
      class WinrmBootstrapProtocol < BootstrapProtocol

        def initialize(app)
          @bootstrap = if app[:image_os_type] == 'windows'
            load_winrm_deps
            Chef::Knife::BootstrapWindowsWinrm.new
          else
            raise "Invalid protocol specified for image. Use ssh as bootstrap protocol."
          end
          super
        end

        def load_winrm_deps
          require 'winrm'
          require 'em-winrm'
          require 'chef/knife/bootstrap_windows_winrm'
          require 'chef/knife/core/windows_bootstrap_context'
          require 'chef/knife/winrm'
        end

        def init_bootstrap_options
          bootstrap.config[:winrm_user] = @app[:winrm_user] || 'Administrator'
          bootstrap.config[:winrm_password] = @app[:winrm_password]
          bootstrap.config[:winrm_transport] = @app[:winrm_transport]
          bootstrap.config[:winrm_port] = @app[:winrm_port]
          super
        end

        def wait_for_server_ready
          print "\n#{ui.color("Waiting for winrm to host (#{@app[:bootstrap_ip_address]})", :magenta)}"
          print(".") until tcp_test_winrm(@app[:bootstrap_ip_address], @app[:winrm_port])
        end

        def tcp_test_winrm(hostname, port)
          TCPSocket.new(hostname, port)
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
        end

      end
    end
  end
end
