#
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
#

class Chef
  class Knife
    class Cloud
      module ServerOptions
        def self.included(includer)
          includer.class_eval do
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