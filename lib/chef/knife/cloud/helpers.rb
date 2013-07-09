
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

      end
    end
  end
end
