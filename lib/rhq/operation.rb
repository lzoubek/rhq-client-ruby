module RHQ
  class OperationHistory < BaseObject
    
    attr_reader :client, :id, :href, :json

    def initialize(client, json)
      @client = client
      @json = json
      @href = link(json,"self")
      self
    end

    def refresh
      @json = @client.operation_history(@href).json
    end

    def status
      @json["status"]
    end

    def result
      @json["result"]
    end

    def wait_for
      while self.status == "In Progress" do
        refresh
        sleep(@client.options[:poll_interval])
      end
    end 

  end
end
