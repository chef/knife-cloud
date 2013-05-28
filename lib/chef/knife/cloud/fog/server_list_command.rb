
require 'fog'
require 'chef/knife/cloud/server/list_command'

class Chef
  class Knife
    class Cloud
      class FogServerListCommand < ServerListCommand

        def exec_command(*params)
          # exec the cmd
          response = @service.connection.servers.all

          # handle the response
          handleResponse(response)
        end

        # When column_list is nil display all
        # columns_with_info is array of hash with label, key and attribute formatting callback, ex [{'label' => "Label text", key => 'key', formatter_callback => callback_method}, ...]
        def handleResponse(servers, columns_with_info = [])
          # display column wise only if numbers of columns is less than 8, else as a json for readable display.
          begin
            server_list = columns_with_info.map { |col_info| ui.color(col_info[:label], :bold) } if columns_with_info.length > 0
            servers.sort_by(&:id).each do |server|
              if columns_with_info.length > 0
                columns_with_info.each do |col_info|
                  server_list << (col_info[:formatter_callback].nil? ? server.send(col_info[:key]).to_s : col_info[:formatter_callback].call(server.send(col_info[:key])))
                end
              else
                puts server.to_json
                puts "\n"
              end
            end
          rescue Excon::Errors::BadRequest => e
            response = Chef::JSONCompat.from_json(e.response.body)
            ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
            raise e
          end
          puts ui.list(server_list, :uneven_columns_across, 8) if columns_with_info.length > 0
        end

        def format_server_state(state)
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