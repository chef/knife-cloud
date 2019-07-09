#
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

class Chef
  class Knife
    class Cloud
      module Helpers

        # Additional helpers
        def msg_pair(label, value, color = :cyan)
          if value && !value.to_s.empty?
            puts "#{ui.color(label, color)}: #{value}"
          end
        end

        def locate_config_value(key)
          key = key.to_sym
          config[key] || Chef::Config[:knife][key]
        end

        def create_service_instance
          raise Chef::Exceptions::Override, "You must override create_service_instance in #{self} to create cloud specific service"
        end

        def execute_command
          raise Chef::Exceptions::Override, "You must override execute_command in #{self}"
        end

        # Derived classes can override before_exec_command and after_exec_command
        def before_exec_command; end

        def after_exec_command; end

        def set_default_config; end

        def validate!(*keys)
          # validates necessary options/params to carry out the command.
          # subclasses to implement this.
          errors = []
          keys.each do |k|
            errors << "You did not provide a valid '#{pretty_key(k)}' value." if locate_config_value(k).nil?
          end
          error_message = ""
          raise CloudExceptions::ValidationError, error_message if errors.each { |e| ui.error(e); error_message = "#{error_message} #{e}." }.any?
        end

        def validate_params!; end

        def pretty_key(key)
          key.to_s.tr("_", " ").gsub(/\w+/) { |w| (w =~ /(ssh)|(aws)/i) ? w.upcase : w.capitalize }
        end

      end
    end
  end
end
