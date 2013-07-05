

class Chef
  class Knife
    class Cloud
      class CloudExceptions
        class ServerCreateError < RuntimeError; end
        class ServerDeleteError < RuntimeError; end
        class ServerListingError < RuntimeError; end
        class ImageListingError < RuntimeError; end
        class ServerCreateDependenciesError < RuntimeError; end
        class BootstrapError < RuntimeError; end
      end
    end
  end
end