
require 'chef/knife/core/ui'

class Chef
  class Knife

    class Cloud
      class Command
        attr_accessor :service, :ui

        def initialize(app, service) # here app is the main cli object.
          @app = app
          @service = service
          @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
        end

        def custom_arguments

        end

        def run
          # validate options required for server creation.
          validate!

          # Perform any steps before handling the command
          before_handler

          # exec the actual cmd
          exec_command

          # Perform any steps after handling the command
          after_handler
        end

        # Derived classes can override before_handler and after_handler
        def before_handler
        end

        def after_handler
        end

        def validate!
          # validates necessary options/params to carry out the command.
          # subclasses to implement this.
        end

        # Helpers/utility method
        def msg_pair(label, value, color=:cyan)
          if value && !value.to_s.empty?
            puts "#{ui.color(label, color)}: #{value}"
          end
        end

      end # class Command
    end
  end
end