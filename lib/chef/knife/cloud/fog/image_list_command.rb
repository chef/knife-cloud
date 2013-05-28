
require 'fog'
require 'chef/knife/cloud/command'

class Chef
  class Knife
    class Cloud
      class FogImageListCommand < Command
        attr_accessor :image_filters # array of filters in form {:attribute => attribute-name, :regex => 'filter regex value'}

        def exec_command(*params)
          @image_filters = params[0]  # TODO - we can also take this from cli, for now let cloud-plugin set this.

          # exec the cmd
          response = @service.connection.images.all

          # handle the response
          handleResponse(response)
        end

        def is_image_filtered?(attribute, value)
          image_filters.each do |filter|
            if attribute == filter[:attribute] and value =~ filter[:regex]
              return true
            end
          end
          false
        end

        # When columns_with_info is nil display all
        # columns_with_info is array of hash with label, key and attribute formatting callback, ex [{'label' => "Label text", key => 'key', formatter_callback => callback_method}, ...]
        def handleResponse(images, columns_with_info = [])
          # display column wise only if columns_with_info is specified, else as a json for readable display.
          begin
            image_list = columns_with_info.map { |col_info| ui.color(col_info[:label], :bold) } if columns_with_info.length > 0
            images.sort_by(&:id).each do |image|
              image_filtered = false
              if columns_with_info.length > 0
                list = []
                columns_with_info.each do |col_info|
                  value = (col_info[:formatter_callback].nil? ? image.send(col_info[:key]).to_s : col_info[:formatter_callback].call(image.send(col_info[:key])))
                  image_filtered = true if is_image_filtered?(col_info[:key], value)
                  list << value
                end
                image_list.concat(list) unless image_filtered
              else
                puts image.to_json
                puts "\n"
              end
            end
          rescue Excon::Errors::BadRequest => e
            response = Chef::JSONCompat.from_json(e.response.body)
            ui.fatal("Unknown image error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
            raise e
          end
          puts ui.list(image_list, :uneven_columns_across, 8) if columns_with_info.length > 0
        end

      end # class FogImageListCommand
    end
  end
end