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
              :proc => Proc.new { |key| Chef::Config[:knife][:ssh_port] = key }

            option :ssh_gateway,
              :long => "--ssh-gateway GATEWAY",
              :description => "The ssh gateway",
              :proc => Proc.new { |key| Chef::Config[:knife][:ssh_gateway] = key }

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

            option :distro,
              :short => "-d DISTRO",
              :long => "--distro DISTRO",
              :description => "Bootstrap a distro using a template"

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
              :description => "Full path to location of template to use",
              :proc => Proc.new { |t| Chef::Config[:knife][:template_file] = t },
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
      
            option :secret,
              :short => "-s SECRET",
              :long  => "--secret ",
              :description => "The secret key to use to encrypt data bag item values"

            option :secret_file,
              :long => "--secret-file SECRET_FILE",
              :description => "A file containing the secret key to use to encrypt data bag item values"

          end
        end

      end # module ends
    end
  end
end
