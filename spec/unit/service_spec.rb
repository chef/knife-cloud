#
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright (c) Chef Software Inc.
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

require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require "chef/knife/cloud/service"

describe Chef::Knife::Cloud::Service do

  let (:instance) { Chef::Knife::Cloud::Service.new(config: {}) }

  it { expect { instance }.to_not raise_error }

  it { expect { instance.connection }.to raise_error(Chef::Exceptions::Override, "You must override connection in #{instance}") }

  it { expect { instance.create_server }.to raise_error(Chef::Exceptions::Override, "You must override create_server in #{instance}") }

  it { expect { instance.delete_server(:server_name) }.to raise_error(Chef::Exceptions::Override, "You must override delete_server in #{instance}") }

  it { expect { instance.delete_server }.to raise_error(ArgumentError) }

  it { expect { instance.list_servers }.to raise_error(Chef::Exceptions::Override, "You must override list_servers in #{instance}") }

  it { expect { instance.list_images }.to raise_error(ArgumentError) }

  it { expect { instance.list_images(:image_filters) }.to raise_error(Chef::Exceptions::Override, "You must override list_images in #{instance}") }

  it { expect { instance.list_resource_configurations }.to raise_error(Chef::Exceptions::Override, "You must override list_resource_configurations in #{instance}") }

  it { expect { Chef::Knife::Cloud::Service.new(auth_params: { provider: "Any Cloud Provider" }, config: {}) }.to_not raise_error }

end
