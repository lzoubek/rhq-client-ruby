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

    def running?
      self.status == "In Progress"
    end

    def wait_for
      while self.running? do
        refresh
        sleep(@client.options[:poll_delay])
      end
    end

  end
end
