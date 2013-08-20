#
# Copyright:: Copyright (c) 2013 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  class Knife
    class Cloud
      class CloudExceptions
        class KnifeCloudError < RuntimeError; end
        class ServiceConnectionError < KnifeCloudError; end
        class ValidationError < KnifeCloudError; end
        class ServerCreateError < KnifeCloudError; end
        class ServerSetupError < KnifeCloudError; end
        class ServerDeleteError < KnifeCloudError; end
        class ServerListingError < KnifeCloudError; end
        class ImageListingError < KnifeCloudError; end
        class ServerCreateDependenciesError < KnifeCloudError; end
        class BootstrapError < KnifeCloudError; end
      end
    end
  end
end

