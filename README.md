# Knife Cloud

[![Build Status](https://travis-ci.org/chef/knife-cloud.svg?branch=master)](https://travis-ci.org/chef/knife-cloud)
[![Code Climate](http://img.shields.io/codeclimate/github/opscode/knife-cloud.svg)][codeclimate]

[codeclimate]: https://codeclimate.com/github/chef/knife-cloud

## Description

`knife-cloud` is a library for implementing knife plugins that integrate cloud
infrastructure with Chef. For more information about knife and Chef visit https://chef.io/chef.

## Purpose

The knife-cloud library has been designed to integrate the common tasks of all knife plugins. As a developer of a knife plugin, you will not have to worry about writing generic code in your plugin, eg: the Chef bootstrap code or SSH / WinRM connection code.

## Installation

This library is distributed as a Ruby Gem. To install it, run:

    $ gem install knife-cloud
    $ # OR
    $ chef exec gem install knife-cloud

Depending on your system's configuration, you may need to run this command with root privileges.
Alternatively, you can build the gem from the knife-cloud source code.

	$ git clone https://github.com/chef/knife-cloud
	$ cd knife-cloud
	$ rake gem
	$ gem install knife-cloud-x.y.z.gem

## Writing your custom plugin

General documentation of how to develop a knife plugin can be found in
[Chef documentation](http://docs.chef.io/plugin_knife_custom.html). Use of
the `knife-cloud` gem to implement the plugin automates many aspects of the
process.

Here is an example of how `knife-cloud` can be used. First, create a new ruby project, say knife-myplugin. Add the knife-cloud gem to its gemspec.

Sample gemspec:

	# -*- encoding: utf-8 -*-
	$:.push File.expand_path("../lib", __FILE__)
	require "knife-myplugin/version"

	Gem::Specification.new do |s|
	  s.name        = "knife-myplugin"
	  s.version     = Knife::Myplugin::VERSION
	  s.platform    = Gem::Platform::RUBY
	  s.has_rdoc = true
	  s.extra_rdoc_files = ["README.md", "LICENSE" ]
	  s.authors     = ["RockingSoul"]
	  s.email       = ["rocking.soul@dreamworld.com"]
	  s.homepage    = "https://github.com/dreamworld/knife-myplugin"
	  s.summary     = %q{TODO}
	  s.description = %q{TODO}

	  s.files         = `git ls-files`.split("\n")
	  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
	  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
	  s.require_paths = ["lib"]

	  s.add_dependency "knife-cloud"

	  %w(rspec-core rspec-expectations rspec-mocks rspec_junit_formatter).each { |gem| s.add_development_dependency gem }
	end

Sample Gemfile:

	source "https://rubygems.org"

	# Specify your gem's dependencies in knife-<yourcloud>.gemspec
	gemspec

	group :development do
	  gem 'rspec', '>= 2.7.0'
	  gem 'guard-rspec'
	  gem 'rspec_junit_formatter'
	  gem 'rake'
	  gem 'mixlib-shellout'
	end

### Code structure

Create a new ruby project, say knife-myplugin. Its code structure will look like:

	lib
		chef
			knife
				cloud
					myplugin_service.rb
					myplugin_service_options.rb
					myplugin_server_create_options.rb
				myplugin_server_create.rb
				myplugin_server_delete.rb
				myplugin_server_list.rb
				myplugin_flavor_list.rb

### Service

- myplugin_service.rb

Knife-cloud has a wrapper written for the Fog service. It can be used in your plugin as mentioned in the steps below. If ruby Fog does not have support for your cloud provider, you will have to write your own Service class analogous to the Chef::Knife::Cloud::FogService class which is defined in knife-cloud.
* Add a dependency on the desired version of the `Fog` gem to your plugin's gemspec.
* Implement your Service class which should inherit from the FogService class.

Example Code:

	require 'chef/knife/cloud/fog/service'
	class Chef
	  class Knife
		class Cloud
		  class MypluginService < FogService

			def initialize(options = {})
				# TODO - Add cloud specific auth params to be passed to fog connection. See knife-openstack for real life example.
				super(options.merge({
                              :auth_params => {
                                :my_provider => 'MyPlugin',
                                :my_name => 'demo_name',
								:my_password => 'demo_password'
                }}))
			end

		  end
		end
	  end
	end

#### Service Options

- myplugin_service_options.rb

This inherits all the options provided by Fog. You will have to add any cloud specific auth options.

Example Code:

	require 'chef/knife/cloud/fog/options'
	class Chef
	  class Knife
		class Cloud
		  module MypluginServiceOptions

		   def self.included(includer)
			  includer.class_eval do
				include FogOptions

				# TODO - define your cloud specific auth options.
				# Example:
				# Myplugin Connection params.
				# option :azure_username,
				#  :short => "-A USERNAME",
				#  :long => "--myplugin-username KEY",
				#  :description => "Your Myplugin Username",
				#  :proc => Proc.new { |key| Chef::Config[:knife][:myplugin_username] = key }
			  end
			end
		  end
		end
	  end
	end

### Server Create Command

- myplugin_server_create.rb

This class will inherit from the Chef::Knife::Cloud::ServerCreateCommand class.

	require 'chef/knife/cloud/server/create_command'
	require 'chef/knife/myplugin_helpers'
	require 'chef/knife/cloud/myplugin_server_create_options'
	require 'chef/knife/cloud/myplugin_service'
	require 'chef/knife/cloud/myplugin_service_options'
	require 'chef/knife/cloud/exceptions'

	class Chef
	  class Knife
		class Cloud
		  class MypluginServerCreate < ServerCreateCommand
			include MypluginHelpers
			include MypluginServerCreateOptions
			include MypluginServiceOptions

			banner "knife myplugin server create (options)"

		  end
		end
	  end
	end

##### Override the methods below for plugin specific execution
- before_exec_command

- after_exec_command

- before_bootstrap

- validate_params!

##### Code Example

Following is the code template for the above methods

		def before_exec_command
            # setup the create options
            # TODO - update this section to define the server_def that should be passed to fog for creating VM. This will be specific to your cloud.
            # Example:
            @create_options = {
              :server_def => {
                # servers require a name, knife-cloud generates the chef_node_name
                :name => config[:chef_node_name],
                :image_ref => locate_config_value(:image),
                :flavor_ref => locate_config_value(:flavor),
                #...
              },
              :server_create_timeout => locate_config_value(:server_create_timeout)
            }

            @create_options[:server_def].merge!({:user_data => locate_config_value(:user_data)}) if locate_config_value(:user_data)

            Chef::Log.debug("Create server params - server_def = #{@create_options[:server_def]}")

            # TODO - Update the columns info with the keys and callbacks required as per fog object returned for your cloud. Framework looks for 'key' on your image object hash returned by fog. If you need the values to be formatted or if your value is another object that needs to be looked up use value_callback.
            # Example:
            @columns_with_info = [
              {:label => 'Instance ID', :key => 'id'},
              {:label => 'Name', :key => 'name'},
              {:label => 'Public IP', :key => 'addresses', :value_callback => method(:primary_public_ip_address)},
              {:label => 'Private IP', :key => 'addresses', :value_callback => method(:primary_private_ip_address)},
              {:label => 'Flavor', :key => 'flavor', :value_callback => method(:get_id)},
              {:label => 'Image', :key => 'image', :value_callback => method(:get_id)},
              {:label => 'Keypair', :key => 'key_name'},
              {:label => 'State', :key => 'state'}
            ]
            super
        end

        def get_id(value)
          value['id']
        end

        # Setup the floating ip after server creation.
        def after_exec_command
          # Any action you want to perform post VM creation in your cloud.
          # Example say assigning floating IP to the newly created VM.
          # Make calls to "service" object if you need any information for cloud, example service.connection.addresses
          # Make call to "server" object if you want set properties on newly created VM, example server.associate_address(floating_address)

          super
        end

        def before_bootstrap
          super
          # TODO - Set the IP address that should be used for connection with the newly created VM. This IP address is used for bootstrapping the VM and should be accessible from knife workstation.

          # your logic goes here to set bootstrap_ip_address...

          Chef::Log.debug("Bootstrap IP Address: #{bootstrap_ip_address}")
          if bootstrap_ip_address.nil?
            error_message = "No IP address available for bootstrapping."
            ui.error(error_message)
            raise CloudExceptions::BootstrapError, error_message
          end
          config[:bootstrap_ip_address] = bootstrap_ip_address
        end

        def validate_params!
          super
          errors = []

          # TODO - Add your validation here for any create server parameters and populate errors [] with error message strings.

          # errors << "your error message" if some_param_undefined

          error_message = ""
          raise CloudExceptions::ValidationError, error_message if errors.each{|e| ui.error(e); error_message = "#{error_message} #{e}."}.any?
        end

### Server Delete Command

- myplugin_server_delete.rb

You may just need to create your MypluginServerDelete class here. Unless your plugin has some very specific delete server case, you can leave the code just like shown in the example below:

	require 'chef/knife/cloud/server/delete_options'
	require 'chef/knife/cloud/server/delete_command'
	require 'chef/knife/cloud/myplugin_service'
	require 'chef/knife/cloud/myplugin_service_options'
	require 'chef/knife/myplugin_helpers'

	class Chef
	  class Knife
		class Cloud
		  class MypluginServerDelete < ServerDeleteCommand
			include ServerDeleteOptions
			include MypluginServiceOptions
			include MypluginHelpers

			banner "knife myplugin server delete INSTANCEID [INSTANCEID] (options)"

		  end
		end
	  end
	end

### Server List Command

- myplugin_server_list.rb

Your class MypluginServerList should inherit from Chef::Knife::Cloud::ServerListCommand class.

Example -
	require 'chef/knife/cloud/server/list_command'
	require 'chef/knife/myplugin_helpers'
	require 'chef/knife/cloud/myplugin_service_options'
	require 'chef/knife/cloud/server/list_options'

	class Chef
	  class Knife
		class Cloud
		  class MypluginServerList < ServerListCommand
			include MypluginHelpers
			include MypluginServiceOptions
			include ServerListOptions

			banner "knife myplugin server list (options)"

			def before_exec_command
			  # TODO - Update the columns info with the keys and callbacks required as per fog object returned for your cloud. Framework looks for 'key' on your server object hash returned by fog. If you need the values to be formatted or if your value is another object that needs to be looked up use value_callback.

			  @columns_with_info = [
				{:label => 'Instance ID', :key => 'id'},
				{:label => 'Name', :key => 'name'},
				{:label => 'Public IP', :key => 'addresses', :value_callback => method(:your_callback)},
				#...
			  ]
			  super
			end

			# TODO - callback example, this gets a object/value returned by server.addresses
			def your_callback (addresses)
			  #...
			end

		  end
		end
	  end
	end

### Flavor List Command

- myplugin_flavor_list.rb

For all other list commands other than the server-list, they must inherit from the Chef::Knife::Cloud::ResourceListCommand class.

Example -

	require 'chef/knife/cloud/list_resource_command'
	require 'chef/knife/myplugin_helpers'
	require 'chef/knife/cloud/myplugin_service_options'

	class Chef
	  class Knife
		class Cloud
		  class MypluginFlavorList < ResourceListCommand
			include MypluginHelpers
			include MypluginServiceOptions

			banner "knife myplugin flavor list (options)"

			def before_exec_command
			  # Set columns_with_info map
			  # TODO - Update the columns info with the keys and callbacks required as per fog object returned for your cloud. Framework looks for 'key' on your flavor object hash returned by fog. If you need the values to be formatted or if your value is another object that needs to be looked up use value_callback.
			  # Example:
			  @columns_with_info = [
				{:label => 'ID', :key => 'id'},
				{:label => 'Name', :key => 'name'},
				{:label => 'Virtual CPUs', :key => 'vcpus'},
				{:label => 'RAM', :key => 'ram', :value_callback => method(:ram_in_mb)},
				{:label => 'Disk', :key => 'disk', :value_callback => method(:disk_in_gb)}
			  ]
			end

			def query_resource
			  @service.list_resource_configurations
			end

			# TODO - This is just for example
			def ram_in_mb(ram)
			  "#{ram} MB"
			end

			# TODO - This is just for example
			def disk_in_gb(disk)
			  "#{disk} GB"
			end

		  end
		end
	  end
	end

## License

Copyright:: Copyright (c) 2014-2015 Chef Software, Inc.

License:: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
