
require 'chef/knife/core/ui'
class Chef
  class Knife
    class Cloud
      class BootstrapProtocol

        attr_accessor :bootstrap, :ui

        def initialize(config)
          @config = config
          @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {}) # TODO - reuse app level.
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
          bootstrap.name_args = @config[:bootstrap_ip_address]
          bootstrap.config[:chef_node_name] = @config[:chef_node_name]
          bootstrap.config[:run_list] = @config[:run_list]
          bootstrap.config[:prerelease] = @config[:prerelease]
          bootstrap.config[:bootstrap_version] = @config[:bootstrap_version]
          bootstrap.config[:distro] = @config[:distro]
          bootstrap.config[:template_file] = @config[:template_file]
          bootstrap.config[:bootstrap_proxy] = @config[:bootstrap_proxy]
          bootstrap.config[:environment] = @config[:environment]
          # see chef/knife/bootstrap.rb #warn_chef_config_secret_key.
          bootstrap.config[:encrypted_data_bag_secret] = @config[:encrypted_data_bag_secret]
          bootstrap.config[:encrypted_data_bag_secret_file] = @config[:encrypted_data_bag_secret_file]
        end

      end
    end
  end
end
