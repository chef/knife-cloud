
require 'chef/knife/core/ui'
class Chef
  class Knife
    class Cloud
      class BootstrapProtocol

        attr_accessor :bootstrap, :ui

        def initialize(app)
          @app = app
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
          bootstrap.name_args = @app[:bootstrap_ip_address]
          bootstrap.config[:chef_node_name] = @app[:chef_node_name]
          bootstrap.config[:run_list] = @app[:run_list]
          bootstrap.config[:prerelease] = @app[:prerelease]
          bootstrap.config[:bootstrap_version] = @app[:bootstrap_version]
          bootstrap.config[:distro] = @app[:distro]
          bootstrap.config[:template_file] = @app[:template_file]
          bootstrap.config[:bootstrap_proxy] = @app[:bootstrap_proxy]
          bootstrap.config[:environment] = @app[:environment]
          # see chef/knife/bootstrap.rb #warn_chef_config_secret_key.
          bootstrap.config[:encrypted_data_bag_secret] = @app[:encrypted_data_bag_secret]
          bootstrap.config[:encrypted_data_bag_secret_file] = @app[:encrypted_data_bag_secret_file]
        end

      end
    end
  end
end
