module RHQ
  class Resource < BaseObject
    
    attr_reader :coregui

    def initialize(client, json)
      @client = client
      @json = json
      @id = json["resourceId"]
      @coregui = link(json,"coregui")
      self
    end

    def availability
      @json["availability"]
    end

    def operation(name, params={})
      # find operation
      defs = operation_definitions.select {|op| op["name"] == name}
      if defs.empty?
        raise RhqException::new("Operation [#{name}] does not exist for resource #{@json}")
      end
      op_def = defs[0]
      # create draft schedule and fill with parameters
      draft = @client.operation_create(op_def["id"], @id)
      draft["readyToSubmit"] = true
      draft["params"] = default_params(op_def).merge(params)

      # schedule and return
      schedule = @client.operation_schedule(draft)
      @client.operation_history(link(schedule,"history"))
    end

    private
 
      def default_params(op_def)
        required = op_def["params"].select {|param| param["required"] == true}
        hash = {}
        required.each {|param| hash.merge!({param["name"] => default_param_value(param) }) }
        return hash
      end

      def default_param_value(param)
        if param["defaultValue"].nil?
          if param["type"] == "BOOLEAN"
            return false
          end
        end
        return param["defaultValue"]
      end

      def operation_definitions
        @operation_definitions ||= @client.operation_definitions(@id)
      end


  end
end
