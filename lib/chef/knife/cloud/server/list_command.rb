require 'chef/knife/cloud/list_resource_command'
require 'chef/knife/cloud/exceptions'

class Chef
  class Knife
    class Cloud
      class ServerListCommand < ResourceListCommand
        
        def before_exec_command
          if config[:chef_data]
            begin
              # Chef::Node.list(inflate = true) to use Solr search.
              @node_list = Chef::Node.list(true)
            rescue Errno::ECONNREFUSED => e
              error_message = "Connection error with Chef server. #{e}"
              ui.warn(error_message)
              raise CloudExceptions::ChefServerError, error_message
            end
            
            @chef_data_col_info = [
              {:label => 'Chef Node Name', :key => 'name'},
              {:label => 'Environment', :key => 'chef_environment'},
              {:label => 'FQDN', :key => 'fqdn'},
              {:label => 'Runlist', :key => 'run_list'},
              {:label => 'Tags', :key => 'tags'},
              {:label => 'Platform', :key => 'platform'},
            ]

            if config[:chef_node_attribute]
              @chef_data_col_info << {:label => "#{config[:chef_node_attribute]}", :key => "#{config[:chef_node_attribute]}"}
            end
            @columns_with_info.concat(@chef_data_col_info)
          end
        end

        # Override from base to display chef node data along with server list display.
        def get_resource_col_val(server)
          list = []
          @columns_with_info.each do |col_info|
            if config[:chef_data] && @chef_data_col_info.include?(col_info)
              server_name = service.get_server_name(server)
              if @node_list.include?(server_name)
                node =  @node_list[server_name]
                # Raise serverlisting error on invalid chef_node_attribute.
                if col_info[:key] == config[:chef_node_attribute] && ! node.attribute?(col_info[:key])
                  error_message = "The Node does not have a #{col_info[:key]} attribute."
                  ui.error(error_message)
                  raise CloudExceptions::CloudAPIException, error_message
                else
                  value = (col_info[:value_callback].nil? ? node.send(col_info[:key]).to_s : col_info[:value_callback].call(node.send(col_info[:key])))
                end
              else
                # Set chef data value for those server which is not part chef server.
                value = ""
              end
            else
              value = (col_info[:value_callback].nil? ? server.send(col_info[:key]).to_s : col_info[:value_callback].call(server.send(col_info[:key])))
            end
            list << value
          end
          list
        end

        def query_resource
          @service.list_servers
        end

        def format_server_state(state)
           state = state.to_s.downcase
           state_color =  case state
                          when 'shutting-down','terminated','stopping','stopped','error','shutoff'
                            :red
                          when 'pending','build','paused','suspended','hard_reboot'
                            :yellow
                          else
                            :green
                          end
            ui.color(state, state_color)              
        end

      end # class ServerListCommand
    end
  end
end
