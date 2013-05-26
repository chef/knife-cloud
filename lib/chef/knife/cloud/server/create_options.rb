
require 'chef/knife/winrm_base' # pulls in winrm options
require 'chef/knife/cloud/server/bootstrap_options'

class Chef
  class Knife
    class Cloud
      module ServerCreateOptions

        def self.included(includer)
          includer.class_eval do
            include Chef::Knife::WinrmBase
            include BootstrapOptions

            deps do
              require 'fog'
              require 'readline'
              require 'chef/json_compat'
              require 'chef/knife/bootstrap'
              Chef::Knife::Bootstrap.load_deps
            end

            option :image,
            :short => "-I IMAGE_ID",
            :long => "--image IMAGE_ID",
            :description => "The image ID for the server",
            :proc => Proc.new { |i| Chef::Config[:knife][:image] = i }

            option :flavor,
            :short => "-f FLAVOR_ID",
            :long => "--flavor FLAVOR_ID",
            :description => "The flavor ID of server", # TODO -KD- cloud plugin can override to give examples?
            :proc => Proc.new { |f| Chef::Config[:knife][:flavor] = f }

            option :bootstrap_protocol,
            :long => "--bootstrap-protocol protocol",
            :description => "Protocol to bootstrap Windows servers. options: winrm",
            :default => nil

            option :server_create_timeout,
              :long => "--server-create-timeout timeout",
              :description => "How long to wait until the server is ready; default is 600 seconds",
              :default => 600,
              :proc => Proc.new { |v| Chef::Config[:knife][:server_create_timeouts] = v}

          end
        end

      end # module end
    end
  end
end


