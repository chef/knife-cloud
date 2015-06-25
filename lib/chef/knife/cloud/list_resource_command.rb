#
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright (c) 2013-14 Chef, Inc.
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

class Chef
  class Knife
    class Cloud
      class ResourceListCommand < Command

        def initialize(argv=[])
          super argv
          # columns_with_info is array of hash with label, key and attribute extraction callback, ex [{:label => "Label text", :key => 'key', value_callback => callback_method to extract/format the required value}, ...]
          @columns_with_info = []
          @sort_by_field = "id" # default sort by id
        end

        def execute_command
          # exec the cmd
          resources = query_resource

          # handle the response
          list(resources)
        end

        def query_resource
          # specific resource type must override this.
          raise Chef::Exceptions::Override, "You must override query_resource in #{self.to_s} to return resources."
        end

        def is_resource_filtered?(attribute, value)
          # resource_filters is array of filters in form {:attribute => attribute-name, :regex => 'filter regex value'}
          return false if @resource_filters.nil?
          @resource_filters.each do |filter|
            if attribute == filter[:attribute] and value =~ filter[:regex]
              return true
            end
          end
          false
        end

        # Derived class can override this to add more functionality.
        def get_resource_col_val(resource)
          resource_filtered = false
          list = []
          @columns_with_info.each do |col_info|
            value = (col_info[:value_callback].nil? ? resource.send(col_info[:key]).to_s : col_info[:value_callback].call(resource.send(col_info[:key])))
            if !config[:disable_filter]
              resource_filtered = true if is_resource_filtered?(col_info[:key], value)
            end
            list << value
          end
          return list unless resource_filtered
        end

        # When @columns_with_info is nil display all
        def list(resources)
          if(config[:format] == "summary")
            # display column wise only if @columns_with_info is specified, else as a json for readable display.
            begin
              resource_list = @columns_with_info.map { |col_info| ui.color(col_info[:label], :bold) } if @columns_with_info.length > 0
              resources.sort_by{|x| x.send(@sort_by_field).downcase }.each do |resource|
                if @columns_with_info.length > 0
                  list = get_resource_col_val(resource)
                  resource_list.concat(list) unless list.nil?
                else
                  puts resource.to_json
                  puts "\n"
                end
              end

            rescue => e
              ui.fatal("Unknown resource error : #{e.message}")
              raise e
            end

            puts ui.list(resource_list, :uneven_columns_across, @columns_with_info.length) if @columns_with_info.length > 0
          else
            output(format_for_display(resources))
          end
        end

      end # class ResourceListCommand
    end
  end
end

