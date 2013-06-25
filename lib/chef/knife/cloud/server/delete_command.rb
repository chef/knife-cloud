
require 'chef/knife/cloud/command'
# These two are needed for the '--purge' deletion case
require 'chef/node'
require 'chef/api_client'

class Chef
  class Knife
    class Cloud
      class ServerDeleteCommand < Command
        attr_accessor :server_name, :server

        def exec_command(*params)
          # actual deletion in subclass, specific to implementation.
          raise Chef::Exceptions::Override, "You must override exec_command in #{self.to_s} for server deletion."
        end

        def after_handler
          # delete the node from Chef if purge requested.
          if @app.config[:purge]
            thing_to_delete = @app.config[:chef_node_name] || server_name
            destroy_item(Chef::Node, thing_to_delete, "node")
            destroy_item(Chef::ApiClient, thing_to_delete, "client")
          else
            ui.warn("Corresponding node and client for the #{server_name} server were not deleted and remain registered with the Chef Server")
            end
        end

        # Extracted from Chef::Knife.delete_object, because it has a
        # confirmation step built in... By specifying the '--purge'
        # flag (and also explicitly confirming the server destruction!)
        # the user is already making their intent known.  It is not
        # necessary to make them confirm two more times.
        def destroy_item(klass, name, type_name)
          begin
            object = klass.load(name)
            object.destroy
            ui.warn("Deleted #{type_name} #{name}")
          rescue Net::HTTPServerException
            ui.warn("Could not find a #{type_name} named #{name} to delete!")
          end
        end

      end # class ServerDeleteCommand
    end
  end
end