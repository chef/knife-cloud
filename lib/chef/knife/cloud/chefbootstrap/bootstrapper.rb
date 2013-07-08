
require 'chef/knife/core/ui'
require 'chef/knife/cloud/chefbootstrap/ssh_bootstrap_protocol'
require 'chef/knife/cloud/chefbootstrap/winrm_bootstrap_protocol'
class Chef
  class Knife
    class Cloud
      class Bootstrapper
        attr_accessor :distribution, :protocol, :ui

        def initialize(app)
          @app = app
          @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {}) # TODO - reuse app level.
        end

        def bootstrap
          # uses BootstrapDistribution and BootstrapProtocol to perform bootstrap
          @protocol = create_bootstrap_protocol
          @distribution = create_bootstrap_distribution
          @protocol.send_bootstrap_command
        end

        def create_bootstrap_protocol
          if @app[:bootstrap_protocol].nil? or @app[:bootstrap_protocol] == 'ssh'
            SshBootstrapProtocol.new(@app)
          elsif @app[:bootstrap_protocol] == 'winrm'
            WinrmBootstrapProtocol.new(@app)
          else
            # raise an exception, invalid bootstrap protocol.
            ui.fatal("Invalid bootstrap protocol.")
            raise "Invalid bootstrap protocol."
          end
        end

        def create_bootstrap_distribution

        end

      end
    end
  end
end
