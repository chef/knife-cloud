
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
        # column_list_with_labels is array of hash, ex [{'key' => "key-label"}, ...]
        def handleResponse(servers, column_list_with_labels = nil)
          column_list = JSON.parse(servers.first.to_json).keys
          server_list = column_list.map { |col| ui.color(col, :bold) }

            begin
              servers.sort_by(&:id).each do |server|
                server_json = JSON.parse(server.to_json)
                column_list.each do |key|
                  if key == 'state'
                    server_list << decorate_server_state(server_json[key])
                  else
                    server_list << server_json[key].to_s
                  end
                end
              end
            rescue Excon::Errors::BadRequest => e
              response = Chef::JSONCompat.from_json(e.response.body)
              ui.fatal("Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}")
              raise e
            end
            puts ui.list(server_list, :uneven_columns_across, 8)
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