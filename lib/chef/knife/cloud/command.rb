#
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
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
#

require 'chef/knife'
require "chef/knife/cloud/helpers"
require 'chef/knife/cloud/exceptions'

class Chef
  class Knife

    class Cloud
      class Command < Chef::Knife
        include Cloud::Helpers
        attr_accessor :service, :custom_arguments

        def run
          begin
            # Set dafult config
            set_default_config

            # validate compulsory params
            validate!

            # validate command pre-requisites (cli options)
            validate_params!

            # setup the service
            @service = create_service_instance

            service.ui = ui # for interactive user prompts/messages

            # Perform any steps before handling the command
            before_exec_command

            # exec the actual cmd
            execute_command

            # Perform any steps after handling the command
            after_exec_command
          rescue CloudExceptions::KnifeCloudError => e
            Chef::Log.debug(e.message)
            exit 1
          end
        end

        def create_service_instance
          raise Chef::Exceptions::Override, "You must override create_service_instance in #{self.to_s} to create cloud specific service"
        end

        def execute_command
          raise Chef::Exceptions::Override, "You must override execute_command in #{self.to_s}"
        end

        # Derived classes can override before_exec_command and after_exec_command
        def before_exec_command
        end

        def after_exec_command
        end

        def set_default_config
        end

        def validate!(*keys)
          # validates necessary options/params to carry out the command.
          # subclasses to implement this.
          errors = []
          keys.each do |k|
            errors << "You did not provide a valid '#{pretty_key(k)}' value." if locate_config_value(k).nil?
          end
          error_message = ""
          raise CloudExceptions::ValidationError, error_message if errors.each{|e| ui.error(e); error_message = "#{error_message} #{e}."}.any?
        end

        def validate_params!
        end

        def pretty_key(key)
          key.to_s.gsub(/_/, ' ').gsub(/\w+/){ |w| (w =~ /(ssh)|(aws)/i) ? w.upcase  : w.capitalize }
        end

      end # class Command
    end
  end
end

