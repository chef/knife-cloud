
require 'fog'
require 'chef/knife/cloud/server/list_command'

class Chef
  class Knife
    class Cloud
      class FogServerListCommand < ServerListCommand

        def run
          # validate
          validate!

          # exec the cmd
          response = @service.connection.servers.all
          # wait for response

          # handle the response
          handleResponse(response)
        end

        # When column_list is nil display all
        # column_list_with_labels is hash with label and attribute formatting callback, ex {'key' => {label => 'label-for-key', formatter_callback => callback_method}, ...}
        def handleResponse(servers, column_list_with_info = {})
          # display column wise only if numbers of columns is less than 8, else as a hash for readable display.
          display_as_columns = column_list_with_info.length.between?(1,8)

          column_list = JSON.parse(servers.first.to_json).keys
          server_list = column_list.map { |col| ui.color(column_list_with_info[col].label, :bold) } if display_as_columns

          begin
            servers.sort_by(&:id).each do |server|
              puts "\n{"  if not display_as_columns
              server_json = JSON.parse(server.to_json)
              column_list.each do |key|
                formatter_callback = column_list_with_info[key].formatter_callback if !column_list_with_info[key].nil?
                if key == 'state'
                  if display_as_columns
                    server_list << (formatter_callback.nil? ? decorate_server_state(server_json[key]) : formatter_callback.call(server_json[key]))
                  else
                    puts("#{ui.color(key, :bold)} = " + (formatter_callback.nil? ? decorate_server_state(server_json[key]) : formatter_callback.call(server_json[key])))
                  end
                else
                  if display_as_columns
                    server_list << (formatter_callback.nil? ? server_json[key].to_s : formatter_callback.call(server_json[key]))
                  else
                    puts("#{ui.color(key, :bold)} = " + (formatter_callback.nil? ? server_json[key].to_s : formatter_callback.call(server_json[key])))
                  end
                end
              end
              puts "\n}\n" if not display_as_columns
            end
            rescue Excon::Errors::BadRequest => e
              response = Chef::JSONCompat.from_json(e.response.body)
              ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
              raise e
            end
            puts ui.list(server_list, :uneven_columns_across, 8) if display_as_columns
        end

        def decorate_server_state(state)
           state = state.to_s.downcase
           case state
           when 'shutting-down','terminated','stopping','stopped','error','shutoff'
             ui.color(state, :red)
           when 'pending','build','paused','suspended','hard_reboot'
             ui.color(state, :yellow)
           else
             ui.color(state, :green)
           end
        end

      end # class FogServerListCommand
    end
  end
end