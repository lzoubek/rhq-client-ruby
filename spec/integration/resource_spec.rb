require "#{File.dirname(__FILE__)}/../spec_helper"

describe "Client API" do

  before(:all) do
    setup_client
  end

  it "Should return RHQ Server status" do
    status = @client.status
    expect(status.empty?).to be false
  end

  it "Should import Discovery Queue when not empty" do
    dq = @client.discovery_queue
    if !dq.empty?
      @client.import
    end
    expect(@client.discovery_queue.empty?).to be true
  end

  it "Should return a Platform" do
    resources = @client.resources({:category => "PLATFORM"})
    expect(resources.empty?).to be false
    res = resources[0]
    expect(res.availability).to eql("UP")
    expect(res.coregui.nil?).to be false
  end

end

describe "API Resource lifecycle" do

  before(:all) do
    setup_client
    @resource = @client.resources({:category => "PLATFORM"})[0]
  end

  it "Should schedule resource operation and wait for result" do
    history = @resource.operation "discovery"
    history.wait_for
    expect(history.status).not_to eql "In Progress"
    expect(history.result).not_to be nil
  end

  it "Should fail scheduling invalid operation" do
    expect { @resource.operation "foo" }.to raise_error
  end
end
