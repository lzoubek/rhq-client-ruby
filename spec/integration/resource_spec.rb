require "#{File.dirname(__FILE__)}/../spec_helper"
require "socket"

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

  it "Should return a Platform type" do
    resources = @client.platforms
    expect(resources.empty?).to be false
    res = resources[0]
    expect(res.availability).to eql("UP")
    expect(res.coregui.nil?).to be false
    expect(res.respond_to?(:servers)).to be true
  end


end
describe "Alert lifecycle" do

  before(:all) do
    setup_client
    @resource = @client.platforms[0]
    # create an alert definition with fires alert whenever "viewProcessList" operation succeeds
    @hash = {
      :name => "ruby-client-test-alert",
      :conditionMode => "ANY",
      :priority => "HIGH",
      :enabled => true,
      :recoveryId => 0,
      :dampeningCategory => "NONE",
      :notifications => [],
      :conditions => [{
          :name => "viewProcessList",
          :option => "SUCCESS",
          :category => "CONTROL"
        }
      ]}
      @alert_definition = @client.alert_definition_create(@resource.id, @hash)
      sleep 30 # wait a bit until server activates our alert definition
  end

  after(:all) do
    @client.alert_definition_remove(@alert_definition["id"])
  end

  it "Should CRUD alert definition on resource" do
    ad = @client.alert_definition_create(@resource.id, @hash)
    expect(ad["id"]).to be > 0

    ad = @client.alert_definition(ad["id"])
    expect(ad["id"]).to be > 0

    @client.alert_definition_remove(ad["id"])
    ad = @client.alert_definition(ad["id"])
    expect(ad["deleted"]).to be true
  end

  it "Should Fire & ACK alert" do
    # delete all alerts first
    @resource.alerts.select { |a| a.definition_id == @alert_definition.id}.each { |a|
      @client.http_delete "/alert/#{a.id}"
    }
    expect(@resource.alerts.length).to be 0
    # start operation
    history = @resource.operation "viewProcessList"
    history.wait_for

    alerts = @resource.alerts
    expect(alerts.length).to be 1
    alert = alerts[0]
    expect(alert.acked?).to be false
    alert.ack
    expect(alert.acked?).to be true
    @client.http_delete "/alert/#{alert.id}"
  end

end
describe "Resource lifecycle" do

  before(:all) do
    setup_client
    # we expect to run on single agent box
    @resource = @client.platforms[0]
  end

  it "Should schedule resource operation and wait for result" do
    history = @resource.operation "discovery"
    history.wait_for
    expect(history.status).not_to eql "In Progress"
    expect(history.result).not_to be nil
  end

  it "Should schedule resource operation and return it among operation histories" do
    @resource.operation "discovery"
    histories = @resource.operation_history
    expect(histories.empty?).to be false
    expect(histories.detect {|h| h.running?}).not_to be nil
  end

  it "Should fail scheduling invalid operation" do
    expect { @resource.operation "foo" }.to raise_error
  end

  it "Should return Platform child resources" do
    children = @resource.children
    expect(children.empty?).to be false
    child = children[0]
    expect(child.json["parentId"]).to eql(@resource.id)
    expect(child.availability).to eql("UP")
  end

  it "Should return Platform children typeof AS7 Standalone Servers" do
    children = @resource.children({:type => "JBossAS7 Standalone Server"})
    expect(children.empty?).to be false
    child = children[0]
    expect(child.json["parentId"]).to eql(@resource.id)
  end

  it "Should return Platform AS7 Standalone Servers" do
    children = @resource.servers_as7_standalone
    expect(children.empty?).to be false
    child = children[0]
    expect(child.json["parentId"]).to eql(@resource.id)
  end

  it "Should return Platform's Storage node" do
    children = @resource.servers({:type => "RHQ Storage Node"})
    expect(children.empty?).to be false
    child = children[0]
    expect(child.json["parentId"]).to eql(@resource.id)
  end

  it "Should return a trait value" do
    expect(@resource.trait("Hostname")).not_to be nil
  end

  it "Should be able to find Platform by IP address" do
    # this may not be a good idea on large environments
    platform = nil
    my_ip = Socket.ip_address_list.detect{|i| i.ipv4? and !i.ipv4_loopback?}.ip_address
    adapters = @client.resources_search({:plugin=> "Platforms", :type => "Network Adapter" }).each{ |a|
      if a.trait("Inet4Address") == my_ip
        platform = a.parent
      end
    }
    expect(platform.nil?).to be false
  end

end
