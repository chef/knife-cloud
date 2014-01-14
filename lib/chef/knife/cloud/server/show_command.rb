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
#

require 'chef/knife/cloud/command'
require 'chef/knife/cloud/exceptions'

class Chef
  class Knife
    class Cloud
      class ServerShowCommand < Command

        def initialize(argv=[])
          super argv
          # columns_with_info is array of hash with label, key and attribute extraction callback, ex [{:label => "Label text", :key => 'key', value_callback => callback_method to extract/format the required value}, ...]
          @columns_with_info = []
        end

        def validate_params!
          errors = []
          config[:instance_id] = @name_args.first
          if locate_config_value(:instance_id).nil?
            errors << "You must provide a valid Instance Id"
          end
          error_message = ""
          raise CloudExceptions::ValidationError, error_message if errors.each{|e| ui.error(e); error_message = "#{error_message} #{e}."}.any?
        end

        def execute_command
          server = service.get_server(locate_config_value(:instance_id))
          if server.nil?
            error_message = "Server doesn't exists for this #{locate_config_value(:instance_id)} instance id."
            ui.error(error_message)
            raise CloudExceptions::ServerShowError, error_message
          else
            service.server_summary(server, @columns_with_info)
          end
        end
      end
    end
  end
end
