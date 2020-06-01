#
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) Chef Software Inc.
#

class Chef
  class Knife
    class Cloud
      module FogOptions

        def self.included(includer)
          includer.instance_eval do
            option :fog_version,
              long: "--fog-version version",
              description: "Fog gem version to use. Use the ruby gem version strings",
              default: ""

            option :api_endpoint,
              long: "--api-endpoint ENDPOINT",
              description: "Your API endpoint. Eg, for Eucalyptus it can be 'http://ecc.eucalyptus.com:8773/services/Eucalyptus'"

          end
        end
      end
    end
  end
end
