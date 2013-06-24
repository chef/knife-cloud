
class Chef
  class Knife
    class Cloud
      module ServerDeleteOptions

        def self.included(includer)
          includer.class_eval do
            option :purge,
              :short => "-P",
              :long => "--purge",
              :boolean => true,
              :default => false,
              :description => "Destroy corresponding node and client on the Chef Server, in addition to destroying the Cloud node itself. Assumes node and client have the same name as the server (if not, add the '--node-name' option)."

            option :chef_node_name,
              :short => "-N NAME",
              :long => "--node-name NAME",
              :description => "The name of the node and client to delete, if it differs from the server name. Only has meaning when used with the '--purge' option."
          end
        end

      end
    end
  end
end