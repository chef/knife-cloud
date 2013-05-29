
require 'fog'
require 'chef/knife/cloud/list_resource_command'

class Chef
  class Knife
    class Cloud
      class FogServerListCommand < ResourceListCommand

        def query_resource
          @service.connection.servers.all
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