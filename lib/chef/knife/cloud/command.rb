
require 'chef/knife/core/ui'

class Chef
  class Knife

    class Cloud
      class Command
        attr_accessor :cloud_endpoint, :cloud_user, :cloud_password, :ui

        def initialize(app, service) # here app is the main cli object.
          @app = app
          @service = service
          @ui ||= Chef::Knife::UI.new(STDOUT, STDERR, STDIN, {})
        end

        def custom_arguments

        end

        def run
          # exec the cmd
          # wait for response
          # handle the response
        end

        def validate!
          # validates necessary options/params to carry out the command.
          # subclasses to implement this.
        end

      end # class Command
    end
  end
end