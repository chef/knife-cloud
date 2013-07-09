require 'chef/knife/cloud/fog/service'

shared_examples_for Chef::Knife::Cloud::FogService do |instance|
  describe "#connection" do
    it "creates a connection to fog service." do
      Fog::Compute.should_receive(:new)
      instance.connection
    end
  end

  describe "#delete" do
    it "deletes the server." do
      server = double()
      instance.stub(:puts)
      instance.stub_chain(:connection, :servers, :get).and_return(server)
      server.should_receive(:name).ordered
      server.should_receive(:id).ordered
      instance.stub_chain(:ui, :confirm).ordered
      server.should_receive(:destroy).ordered
      instance.delete_server(:server_name)
    end

    it "throws error message when the server cannot be located." do
      server_name = "invalid_server_name"
      error_message = "Could not locate server '#{server_name}'."
      instance.stub_chain(:connection, :servers, :get).and_return(nil)
      instance.stub_chain(:ui, :error).with(error_message)
      expect { instance.delete_server(server_name) }.to raise_error(Chef::Knife::Cloud::CloudExceptions::ServerDeleteError)
    end

    pending "throws error message when it returns an unknown server error." do
      server_name = "invalid_server_name"
      error_message = "Unknown server error (#{}): #{}"
      instance.stub(:response)
      instance.stub_chain(:connection, :servers, :get).and_raise(Excon::Errors::BadRequest.new(error_message))
      expect { instance.delete_server(server_name) }.to raise_error(Excon::Errors::BadRequest)
    end
  end

  describe "#create" do
    before do
      instance.stub(:puts)
      instance.stub(:print)
    end

    it "creates the server." do
      server = double()
      instance.stub_chain(:connection, :servers, :create).and_return(server)
      server.should_receive(:name).ordered
      server.should_receive(:id).ordered
      instance.stub_chain(:ui, :color)
      server.should_receive(:wait_for)
      instance.create_server({:server_create_timeout => 600})
    end
  end
end