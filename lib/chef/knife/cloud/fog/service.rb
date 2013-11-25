#
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
#

require 'chef/knife/cloud/service'
require 'chef/knife/cloud/exceptions'

class Chef
  class Knife
    class Cloud
      class FogService < Service

        def initialize(options = {})
          load_fog_gem
          super
        end

        def load_fog_gem
          begin
            # Load specific version of fog. Any other classes/modules using fog are loaded after this.
            gem "fog", Chef::Config[:knife][:cloud_fog_version]
            require 'fog'
            Chef::Log.debug("Using fog version: #{Gem.loaded_specs["fog"].version}")
          rescue Exception => e
            Chef::Log.error "Error loading fog gem."
            exit 1
          end
        end

        def connection
          add_api_endpoint
          @connection ||= begin
              connection = Fog::Compute.new(@auth_params)
                          rescue Excon::Errors::Unauthorized => e
                            error_message = "Connection failure, please check your username and password."
                            ui.fatal(error_message)
                            raise CloudExceptions::ServiceConnectionError, "#{e.message}. #{error_message}"
                          rescue Excon::Errors::SocketError => e
                            error_message = "Connection failure, please check your authentication URL."
                            ui.fatal(error_message)
                            raise CloudExceptions::ServiceConnectionError, "#{e.message}. #{error_message}"
                          end
        end

        # cloud server specific implementation methods for commands.
        def create_server(options = {})
          begin
            add_custom_arguments(options[:server_def])
            server = connection.servers.create(options[:server_def])
          rescue Excon::Errors::BadRequest => e
            response = Chef::JSONCompat.from_json(e.response.body)
            if response['badRequest']['code'] == 400
              message = "Bad request (400): #{response['badRequest']['message']}"
              ui.fatal(message)
            else
              message = "Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}"
              ui.fatal(message)
            end
            raise CloudExceptions::ServerCreateError, message
          rescue Fog::Errors::Error => e
            raise CloudExceptions::ServerCreateError, e.message
          end

          print "\n#{ui.color("Waiting for server [wait time = #{options[:server_create_timeout]}]", :magenta)}"

          # wait for it to be ready to do stuff
          server.wait_for(Integer(options[:server_create_timeout])) { print "."; ready? }

          puts("\n")
          server
        end

        def delete_server(server_name)
          begin
            server = connection.servers.get(server_name)

            msg_pair("Instance Name", get_server_name(server))
            msg_pair("Instance ID", server.id)

            puts "\n"
            ui.confirm("Do you really want to delete this server")

            # delete the server
            server.destroy
          rescue NoMethodError
            error_message = "Could not locate server '#{server_name}'."
            ui.error(error_message)
            raise CloudExceptions::ServerDeleteError, error_message
          rescue Excon::Errors::BadRequest => e
            response = Chef::JSONCompat.from_json(e.response.body)
            error_message = "Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}"
            ui.fatal(error_message)
            raise CloudExceptions::ServerDeleteError, error_message
          end
        end

        def list_servers
          begin
            servers = connection.servers.all
          rescue Excon::Errors::BadRequest => e
            response = Chef::JSONCompat.from_json(e.response.body)
            error_message = "Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}"
            ui.fatal(error_message)
            raise CloudExceptions::CloudAPIException, error_message
          end
        end

        def list_images
          begin
            images = connection.images.all
          rescue Excon::Errors::BadRequest => e
            response = Chef::JSONCompat.from_json(e.response.body)
            error_message = "Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}"
            ui.fatal(error_message)
            raise CloudExceptions::CloudAPIException, error_message
          end
        end

        def list_resource_configurations
          begin
            flavors = connection.flavors.all
          rescue Excon::Errors::BadRequest => e
            response = Chef::JSONCompat.from_json(e.response.body)
            error_message = "Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}"
            ui.fatal(error_message)
            raise CloudExceptions::CloudAPIException, error_message
          end
        end

        def delete_server_on_failure(server = nil)
          server.destroy if ! server.nil?
        end

        def add_api_endpoint
          raise Chef::Exceptions::Override, "You must override add_api_endpoint in #{self.to_s} to add endpoint in auth_params for connection"
        end

        def get_server_name(server)
          server.name
        end

        def get_server(instance_id)
          begin
            server = connection.servers.get(instance_id)
          rescue Excon::Errors::BadRequest => e
            response = Chef::JSONCompat.from_json(e.response.body)
            error_message = "Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}"
            ui.fatal(error_message)
            raise CloudExceptions::KnifeCloudError, error_message
          end
        end

        def server_summary(server, columns_with_info = [])
          # columns_with_info is array of hash with label, key and attribute extraction callback, ex [{:label => "Label text", :key => 'key', value => 'the_actual_value', value_callback => callback_method to extract/format the required value}, ...]
          list = []
          columns_with_info.each do |col_info|
            value = if col_info[:value].nil?
                      (col_info[:value_callback].nil? ? server.send(col_info[:key]).to_s : col_info[:value_callback].call(server.send(col_info[:key])))
                    else
                      col_info[:value]
                    end
            if !(value.nil? || value.empty?)
              list << ui.color(col_info[:label], :bold)
              list << value
            end
          end
          puts ui.list(list, :uneven_columns_across, 2) if columns_with_info.length > 0
        end

        def is_image_windows?(image)
          image_info = connection.images.get(image)
          !image_info.nil? ? image_info.platform == 'windows' : false
        end

        def add_custom_arguments
          Chef::Config[:knife][:custom_arguments].map{|args| args.map{|k,v| @auth_params.merge!(k.to_sym => v)}} unless Chef::Config[:knife][:custom_arguments].nil?
        end

        def add_custom_arguments(server_def)
          Chef::Config[:knife][:custom_arguments].map{|args| args.map{|k,v| server_def.merge!(k.to_sym => v)}} unless Chef::Config[:knife][:custom_arguments].nil?
        end
      end
    end
  end
end
