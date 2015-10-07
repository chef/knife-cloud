# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
#
# Copyright:: Copyright (c) 2013 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
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
              :proc => Proc.new { |key| Chef::Config[:knife][:ssh_port] = key },
              :default => "22"

            option :ssh_gateway,
              :long => "--ssh-gateway GATEWAY",
              :description => "The ssh gateway server. Any proxies configured in your ssh config are automatically used by default.",
              :proc => Proc.new { |key| Chef::Config[:knife][:ssh_gateway] = key }

            option :ssh_gateway_identity,
              :long => "--ssh-gateway-identity IDENTITY_FILE",
              :description => "The private key for ssh gateway server",
              :proc => Proc.new { |key| Chef::Config[:knife][:ssh_gateway_identity] = key }

            option :forward_agent,
              :long => "--forward-agent",
              :description => "Enable SSH agent forwarding",
              :boolean => true

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

            option :bootstrap_no_proxy,
              :long => "--bootstrap-no-proxy [NO_PROXY_URL|NO_PROXY_IP]",
              :description => "Do not proxy locations for the node being bootstrapped; this option is used internally by Opscode",
              :proc => Proc.new { |np| Chef::Config[:knife][:bootstrap_no_proxy] = np }

            option :distro,
              :short => "-d DISTRO",
              :long => "--distro DISTRO",
              :description => "Bootstrap a distro using a template. [DEPRECATED] Use -t / --template option instead.",
              :proc => Proc.new { |t|
                Chef::Log.warn("[DEPRECATED] -d / --distro option is deprecated. Use -t / --template option instead.")
                Chef::Config[:knife][:bootstrap_template] = t
              }

            option :bootstrap_template,
              :short => "-t TEMPLATE",
              :long => "--bootstrap-template TEMPLATE",
              :description => "Bootstrap Chef using a built-in or custom template. Set to the full path of an erb template or use one of the built-in templates."

            option :use_sudo,
              :long => "--sudo",
              :description => "Execute the bootstrap via sudo",
              :boolean => true

            option :use_sudo_password,
              :long => "--use-sudo-password",
              :description => "Execute the bootstrap via sudo with password",
              :boolean => false

            option :template_file,
              :long => "--template-file TEMPLATE",
              :description => "Full path to location of template to use. [DEPRECATED] Use -t / --bootstrap-template option instead.",
              :proc        => Proc.new { |v|
                Chef::Log.warn("[DEPRECATED] --template-file option is deprecated. Use -t / --bootstrap-template option instead.")
                v
              }

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

            option :secret,
              :short => "-s SECRET",
              :long  => "--secret ",
              :description => "The secret key to use to encrypt data bag item values"

            option :secret_file,
              :long => "--secret-file SECRET_FILE",
              :description => "A file containing the secret key to use to encrypt data bag item values"

            option :bootstrap_url,
              :long        => "--bootstrap-url URL",
              :description => "URL to a custom installation script",
              :proc        => Proc.new { |u| Chef::Config[:knife][:bootstrap_url] = u }

            option :bootstrap_curl_options,
              :long        => "--bootstrap-curl-options OPTIONS",
              :description => "Add options to curl when install chef-client",
              :proc        => Proc.new { |co| Chef::Config[:knife][:bootstrap_curl_options] = co }

            option :auth_timeout,
              :long => "--auth-timeout MINUTES",
              :description => "The maximum time in minutes to wait to for authentication over the transport to the node to succeed. The default value is 25 minutes.",
              :default => 25

            option :node_ssl_verify_mode,
              :long        => "--node-ssl-verify-mode [peer|none]",
              :description => "Whether or not to verify the SSL cert for all HTTPS requests.",
              :proc        => Proc.new { |v|
                valid_values = ["none", "peer"]
                unless valid_values.include?(v)
                  raise "Invalid value '#{v}' for --node-ssl-verify-mode. Valid values are: #{valid_values.join(", ")}"
                end
              }

            option :node_verify_api_cert,
              :long        => "--[no-]node-verify-api-cert",
              :description => "Verify the SSL cert for HTTPS requests to the Chef server API.",
              :boolean     => true

            option :bootstrap_install_command,
              :long        => "--bootstrap-install-command COMMANDS",
              :description => "Custom command to install chef-client",
              :proc        => Proc.new { |ic| Chef::Config[:knife][:bootstrap_install_command] = ic }

            option :bootstrap_wget_options,
              :long        => "--bootstrap-wget-options OPTIONS",
              :description => "Add options to wget when installing chef-client",
              :proc        => Proc.new { |wo| Chef::Config[:knife][:bootstrap_wget_options] = wo }

            option :bootstrap_vault_file,
              :long        => '--bootstrap-vault-file VAULT_FILE',
              :description => 'A JSON file with a list of vault(s) and item(s) to be updated'

            option :bootstrap_vault_json,
              :long        => '--bootstrap-vault-json VAULT_JSON',
              :description => 'A JSON string with the vault(s) and item(s) to be updated'

            option :bootstrap_vault_item,
              :long        => '--bootstrap-vault-item VAULT_ITEM',
              :description => 'A single vault and item to update as "vault:item"',
              :proc        => Proc.new { |i|
                (vault, item) = i.split(/:/)
                Chef::Config[:knife][:bootstrap_vault_item] ||= {}
                Chef::Config[:knife][:bootstrap_vault_item][vault] ||= []
                Chef::Config[:knife][:bootstrap_vault_item][vault].push(item)
                Chef::Config[:knife][:bootstrap_vault_item]
              }
            option :msi_url,
              :short => "-u URL",
              :long => "--msi-url URL",
              :description => "Location of the Chef Client MSI. The default templates will prefer to download from this location. The MSI will be downloaded from chef.io if not provided.",
              :default => ''
            
            option :install_as_service,
              :long => "--install-as-service",
              :description => "Install chef-client as service in windows machine",
              :default => false

          end
        end
      end # module ends
    end
  end
end
