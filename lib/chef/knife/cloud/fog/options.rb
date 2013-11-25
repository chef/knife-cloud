#
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
#

class Chef
  class Knife
    class Cloud
      module FogOptions

        def self.included(includer)
          includer.instance_eval do
            option :fog_version,
              :long => "--fog-version version",
              :description => "Fog gem version to use. Use the ruby gem version strings",
              :default => "",
              :proc => Proc.new { |v| Chef::Config[:knife][:cloud_fog_version] = v}

            option :api_endpoint,
              :long => "--api-endpoint ENDPOINT",
              :description => "Your API endpoint. Eg, for Eucalyptus it can be 'http://ecc.eucalyptus.com:8773/services/Eucalyptus'",
              :proc => Proc.new { |endpoint| Chef::Config[:knife][:api_endpoint] = endpoint }

            option :custom_arguments,
              :long => "--custom-arguments CUSTOM_ARGUMENTS",
              :description => "Custom arguments to be passed to Fog.",
              :proc => Proc.new {|args| Chef::Config[:knife][:custom_arguments] =  args.split(',').map{|keys| keys.split('=')}.map{|j| Hash[*j.map{|k| k.strip}]}}
          end
        end

      end
    end
  end
end
