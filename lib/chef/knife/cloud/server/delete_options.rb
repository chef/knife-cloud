#
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
#

require 'chef/knife/cloud/server/options'

class Chef
  class Knife
    class Cloud
      module ServerDeleteOptions
        def self.included(includer)
          includer.class_eval do
            include ServerOptions

            option :purge,
              :short => "-P",
              :long => "--purge",
              :boolean => true,
              :default => false,
              :description => "Destroy corresponding node and client on the Chef Server, in addition to destroying the Cloud node itself. Assumes node and client have the same name as the server (if not, add the '--node-name' option)."

          end
        end
      end
    end
  end
end