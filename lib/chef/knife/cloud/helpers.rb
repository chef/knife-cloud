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

require 'erb'

class Chef
  class Knife
    class Cloud
      module Helpers

        # Additional helpers
        def msg_pair(label, value, color=:cyan)
          if value && !value.to_s.empty?
            puts "#{ui.color(label, color)}: #{value}"
          end
        end

        def locate_config_value(key)
          key = key.to_sym
          config[key] || Chef::Config[:knife][key]
        end

        # Usage: ERB.new("Hello <%= name %>!!").result(ERBParams.new(:name => "Ruby World").get_binding)
        class ERBParams
          def initialize(*args)
            args.each do |arg|
              arg.each do |key, value|
                instance_variable_set("@#{key}", value)
                # Add attribute accessor
                eval("class << self; attr_accessor :#{key}; end")
              end
            end
          end

          def get_binding
            binding
          end
        end

        # Usage: ERBCompiler.run("Hello <%= name %>!!", {:name => "Ruby World"})
        class ERBCompiler
          def self.run(template, attributes)
            begin
              ERB.new(template).result(ERBParams.new(attributes).get_binding)
            rescue NameError
              puts "\n** Check whether all necessary ERB template substitution params are defined in attributes argument. #{attributes} \n\n"
              raise 
            end
          end
        end
      end
    end
  end
end

