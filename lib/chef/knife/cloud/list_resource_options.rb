
class Chef
  class Knife
    class Cloud
      module ResourceListOptions

        def self.included(includer)
          includer.class_eval do

            option :disable_filter,
            :long => "--disable-filter",
            :description => "Disable filtering of the current resource listing.",
            :boolean => true,
            :default => false
          end
        end

      end
    end
  end
end