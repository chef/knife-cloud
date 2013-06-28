# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.

require 'spec_helper'
require 'chef/knife/cloud/fog/image_list_command'

describe Chef::Knife::Cloud::FogImageListCommand do

  before do
    # setup dummy app and service objects.
    @app = App.new
    @service = Object.new
    @instance = Chef::Knife::Cloud::FogImageListCommand.new(@app, @service)
  end

  it 'collects all the images .' do
    @images = mock()
    @service.stub_chain(:connection, :images, :all).and_return(@images)
    @instance.query_resource.should == @images
  end

  it 'lists all the images.' do
    @instance.stub(:puts)
    @images = mock()
    @service.stub_chain(:connection, :images, :all).and_return(@images)
    @images.stub(:sort_by).and_return([:a, :b, :c])
    @instance.run
  end

end
