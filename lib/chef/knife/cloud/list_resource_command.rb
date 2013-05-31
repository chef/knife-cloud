
require 'chef/knife/cloud/command'

class Chef
  class Knife
    class Cloud
      class ResourceListCommand < Command
        attr_accessor :resource_filters # array of filters in form {:attribute => attribute-name, :regex => 'filter regex value'}

        def exec_command(*params)
          @resource_filters = params[0] if !params.empty? # TODO - we can also take this from cli, for now let cloud-plugin set this.

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
          return false if resource_filters.nil?
          resource_filters.each do |filter|
            if attribute == filter[:attribute] and value =~ filter[:regex]
              return true
            end
          end
          false
        end

        # When columns_with_info is nil display all
        # columns_with_info is array of hash with label, key and attribute extraction callback, ex [{'label' => "Label text", key => 'key', value_callback => callback_method to extract/format the required value}, ...]
        def list(resources, columns_with_info = [])
          # display column wise only if columns_with_info is specified, else as a json for readable display.
          begin
            resource_list = columns_with_info.map { |col_info| ui.color(col_info[:label], :bold) } if columns_with_info.length > 0
            resources.sort_by(&:id).each do |resource|
              resource_filtered = false
              if columns_with_info.length > 0
                list = []
                columns_with_info.each do |col_info|
                  value = (col_info[:value_callback].nil? ? resource.send(col_info[:key]).to_s : col_info[:value_callback].call(resource.send(col_info[:key])))
                  if !@app.config[:disable_filter]
                    resource_filtered = true if is_resource_filtered?(col_info[:key], value)
                  end
                  list << value
                end
                resource_list.concat(list) unless resource_filtered
              else
                puts resource.to_json
                puts "\n"
              end
            end
          rescue Excon::Errors::BadRequest => e
            response = Chef::JSONCompat.from_json(e.response.body)
            ui.fatal("Unknown resource error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
            raise e
          end
          puts ui.list(resource_list, :uneven_columns_across, columns_with_info.length) if columns_with_info.length > 0
        end

      end # class ResourceListCommand
    end
  end
end