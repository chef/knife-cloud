require 'chef/knife/winrm_base'
require 'chef/knife/core/bootstrap_context'
require 'net/ssh/multi'
class Chef
  class Knife
    class Cloud
      # Ideally chef/knife/bootstap should expose this as module.
      module BootstrapOptions

        def self.included(includer)
          includer.class_eval do

            deps do
              require 'chef/json_compat'
              require 'tempfile'
              require 'highline'
              require 'net/ssh'
              require 'chef/knife/ssh'
              Chef::Knife::Ssh.load_deps
            end

            include Chef::Knife::WinrmBase

            option :ssh_user,
              :short => "-x USERNAME",
              :long => "--ssh-user USERNAME",
              :description => "The ssh username",
              :default => "root"

            option :ssh_password,
              :short => "-P PASSWORD",
              :long => "--ssh-password PASSWORD",
              :description => "The ssh password"

            option :ssh_port,
              :short => "-p PORT",
              :long => "--ssh-port PORT",
              :description => "The ssh port",
              :proc => Proc.new { |key| Chef::Config[:knife][:ssh_port] = key }

            option :ssh_gateway,
              :short => "-G GATEWAY",
              :long => "--ssh-gateway GATEWAY",
              :description => "The ssh gateway",
              :proc => Proc.new { |key| Chef::Config[:knife][:ssh_gateway] = key }

            option :identity_file,
              :short => "-i IDENTITY_FILE",
              :long => "--identity-file IDENTITY_FILE",
              :description => "The SSH identity file used for authentication"

            option :chef_node_name,
              :short => "-N NAME",
              :long => "--node-name NAME",
              :description => "The Chef node name for your new node"

            option :prerelease,
              :long => "--prerelease",
              :description => "Install the pre-release chef gems"

            option :bootstrap_version,
              :long => "--bootstrap-version VERSION",
              :description => "The version of Chef to install",
              :proc => lambda { |v| Chef::Config[:knife][:bootstrap_version] = v }

            option :bootstrap_proxy,
              :long => "--bootstrap-proxy PROXY_URL",
              :description => "The proxy server for the node being bootstrapped",
              :proc => Proc.new { |p| Chef::Config[:knife][:bootstrap_proxy] = p }

            option :distro,
              :short => "-d DISTRO",
              :long => "--distro DISTRO",
              :description => "Bootstrap a distro using a template",
              :default => "chef-full"

            option :use_sudo,
              :long => "--sudo",
              :description => "Execute the bootstrap via sudo",
              :boolean => true

            option :template_file,
              :long => "--template-file TEMPLATE",
              :description => "Full path to location of template to use",
              :default => false

            option :run_list,
              :short => "-r RUN_LIST",
              :long => "--run-list RUN_LIST",
              :description => "Comma separated list of roles/recipes to apply",
              :proc => lambda { |o| o.split(/[\s,]+/) },
              :default => []

            option :first_boot_attributes,
              :short => "-j JSON_ATTRIBS",
              :long => "--json-attributes",
              :description => "A JSON string to be added to the first run of chef-client",
              :proc => lambda { |o| JSON.parse(o) },
              :default => {}

            option :host_key_verify,
              :long => "--[no-]host-key-verify",
              :description => "Verify host key, enabled by default.",
              :boolean => true,
              :default => true

            option :hint,
              :long => "--hint HINT_NAME[=HINT_FILE]",
              :description => "Specify Ohai Hint to be set on the bootstrap target.  Use multiple --hint options to specify multiple hints.",
              :proc => Proc.new { |h|
                Chef::Config[:knife][:hints] ||= Hash.new
                name, path = h.split("=")
                Chef::Config[:knife][:hints][name] = path ? JSON.parse(::File.read(path)) : Hash.new  }
          end
        end

      end # module ends
    end
  end
end
