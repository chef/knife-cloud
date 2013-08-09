require 'chef/knife/cloud/service'

shared_examples_for Chef::Knife::Cloud::Service do |instance|

  describe "#connection" do
    it "creates a connection to fog service." do
      Fog::Compute.should_receive(:new)
      instance.connection
    end
  end

  describe "#delete_server" do
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
  end

  describe "#create_server" do
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