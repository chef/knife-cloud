
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

        def send_bootstrap_command
          wait_for_server_ready
          init_bootstrap_options
          @bootstrap.run
        end

        def init_bootstrap_options
          # set the command bootstrap options.
          bootstrap.name_args = @app.config[:bootstrap_ip_address]
          bootstrap.config[:chef_node_name] = @app.config[:chef_node_name]
          bootstrap.config[:run_list] = @app.config[:run_list]
          bootstrap.config[:prerelease] = @app.config[:prerelease]
          bootstrap.config[:bootstrap_version] = @app.locate_config_value(:bootstrap_version)
          bootstrap.config[:distro] = @app.locate_config_value(:distro)
          bootstrap.config[:template_file] = @app.locate_config_value(:template_file)
          bootstrap.config[:bootstrap_proxy] = @app.locate_config_value(:bootstrap_proxy)
          bootstrap.config[:environment] = @app.config[:environment]
          # TODO -KD- Do we need these two? first seems deprecated as per chef/knife/bootstrap.
          # bootstrap.config[:encrypted_data_bag_secret] = @app.config[:encrypted_data_bag_secret]
          # bootstrap.config[:encrypted_data_bag_secret_file] = @app.config[:encrypted_data_bag_secret_file]
        end

      end
    end
  end
end