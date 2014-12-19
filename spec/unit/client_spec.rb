require "#{File.dirname(__FILE__)}/../spec_helper"

describe RHQ::Client do
  context 'client initialization' do
    it 'should accept no option' do
      RHQ::Client::new('http://localhost:7080/rest','mockuser','mockpass')
    end

    it 'should support no parameters' do
      RHQ::Client::new()
    end

  end

  context 'http comms' do
    before(:each) do
      @client = RHQ::Client::new('http://localhost:7080/rest','mockuser','mockpass')
    end
      
    it "should add Accept: headers" do
      headers = @client.send(:http_headers)
      expect(headers[:accept]).to eql('application/json')
    end

    it "should keep existing Accept: headers" do
      value = "application/json; foo=bar;"
      headers = @client.send(:http_headers, {:accept => value})
      expect(headers[:accept]).to eql(value)
    end
  end
end
