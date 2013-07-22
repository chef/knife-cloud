
require 'chef/knife/cloud/list_resource_command'

class Chef
  class Knife
    class Cloud
      class ServerListCommand < ResourceListCommand

        def query_resource
          @service.list_servers
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

      end # class ServerListCommand
    end
  end
end
