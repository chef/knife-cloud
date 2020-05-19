#
# Author:: Kaustubh Deorukhkar (<kaustubh@clogeny.com>)
# Copyright:: Copyright (c) 2013-2016 Chef Software, Inc.
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

require "chef/knife"
require_relative "helpers"
require_relative "exceptions"

class Chef
  class Knife

    class Cloud
      class Command < Chef::Knife
        include Cloud::Helpers
        attr_accessor :service, :custom_arguments

        def run
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
      end # class Command
    end
  end
end
