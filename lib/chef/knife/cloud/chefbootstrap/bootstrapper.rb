
require 'chef/knife/core/ui'
require 'chef/knife/cloud/chefbootstrap/ssh_bootstrap_protocol'
require 'chef/knife/cloud/chefbootstrap/winrm_bootstrap_protocol'
class Chef
  class Knife
    class Cloud
      class Bootstrapper
        attr_accessor :distribution, :protocol, :ui

        def initialize(config)
          @config = config
          @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {}) # TODO - reuse app level.
        end

        def bootstrap
          # uses BootstrapDistribution and BootstrapProtocol to perform bootstrap
          @protocol = create_bootstrap_protocol
          @protocol.send_bootstrap_command
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
            raise error_message
          end
        end
      end
    end
  end
end
