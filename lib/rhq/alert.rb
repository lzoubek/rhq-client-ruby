require "date"

module RHQ
  class Alert < BaseObject

    attr_reader :client, :id, :href, :json

    def initialize(client, json)
      @client = client
      @json = json
      @href = link(json,"self")
      @id = json["id"]
      self
    end

    def ack
      @client.alert_ack(@id)
      @json = client.alert(@id).json
    end

    def resource
      @client.resource(@json["resource"]["resourceId"])
    end

    def definition_id
      @json["alertDefinition"]["id"]
    end

    def definition
      @client.alert_definition(self.definition_id)
    end

    def priority
      @json["alertDefinition"]["priority"]
    end

    def acked?
      @json["ackTime"] != 0
    end

    def ack_time
      if self.acked?
        return nil
      end
      return Time.at(@json["ackTime"]/100).to_datetime
    end

    def time
      return Time.at(@json["alertTime"]/100).to_datetime
    end

    def result
      @json["result"]
    end

    def is_running
      self.status == "In Progress"
    end

  end
end
