

require 'chef/knife/cloud/server/options'

class Chef
  class Knife
    class Cloud
      module ServerCreateOptions

        def self.included(includer)
          includer.class_eval do
            include ServerOptions

            option :image,
              :short => "-I IMAGE_ID",
              :long => "--image IMAGE_ID",
              :description => "The image ID for the server",
              :proc => Proc.new { |i| Chef::Config[:knife][:image] = i }

            option :image_os_type,
              :short => "-T IMAGE_OS_TYPE",
              :long => "--image-os IMAGE_OS_TYPE",
              :description => "The image os type. options [windows/other]. Only required when cloud does not provide a way to identify image os, default is non-windows",
              :proc => Proc.new { |i| Chef::Config[:knife][:image_os] = i }

            option :flavor,
              :short => "-f FLAVOR_ID",
              :long => "--flavor FLAVOR_ID",
              :description => "The flavor ID of server", # TODO -KD- cloud plugin can override to give examples?
              :proc => Proc.new { |f| Chef::Config[:knife][:flavor] = f }

            option :server_create_timeout,
              :long => "--server-create-timeout timeout",
              :description => "How long to wait until the server is ready; default is 600 seconds",
              :default => 600,
              :proc => Proc.new { |v| Chef::Config[:knife][:server_create_timeout] = v}

          end
        end

      end # module end
    end
  end
end


