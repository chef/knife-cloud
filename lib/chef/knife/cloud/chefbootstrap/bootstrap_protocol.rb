
require 'chef/knife/core/ui'
require 'chef/knife/cloud/helpers'
class Chef
  class Knife
    class Cloud
      class BootstrapProtocol
        include Chef::Knife::Cloud::Helpers

        attr_accessor :bootstrap, :ui
        attr_reader :config

        def initialize(config)
          @config = config
          @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
        end

        def wait_for_server_ready
          raise Chef::Exceptions::Override, "You must override wait_for_server_ready in #{self.to_s}"
        end

        def send_bootstrap_command
          wait_for_server_ready
          init_bootstrap_options
          @bootstrap.run
        end

        def init_bootstrap_options
          # set the command bootstrap options.
          bootstrap.name_args = locate_config_value(:bootstrap_ip_address)
          bootstrap.config[:chef_node_name] = locate_config_value(:chef_node_name)
          bootstrap.config[:run_list] = locate_config_value(:run_list)
          bootstrap.config[:prerelease] = locate_config_value(:prerelease)
          bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
          bootstrap.config[:distro] = locate_config_value(:distro)
          bootstrap.config[:template_file] = locate_config_value(:template_file)
          bootstrap.config[:bootstrap_proxy] = locate_config_value(:bootstrap_proxy)
          bootstrap.config[:environment] = locate_config_value(:environment)
          # see chef/knife/bootstrap.rb #warn_chef_config_secret_key.
          bootstrap.config[:encrypted_data_bag_secret] = locate_config_value(:encrypted_data_bag_secret)
          bootstrap.config[:encrypted_data_bag_secret_file] = locate_config_value(:encrypted_data_bag_secret_file)
        end

      end
    end
  end
end
