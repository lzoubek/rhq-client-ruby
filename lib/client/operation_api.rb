module RHQ
  class Client
    def operation_definitions(id)
      http_get("/operation/definitions?resourceId=%s" % id)
    end

    def operation_create(op_def_id,resource_id)
      http_post("/operation/definition/%s?resourceId=%s" % [op_def_id, resource_id],{})
    end

    def operation_schedule(draft)
      http_put("/operation/%s" % draft["id"], draft)
    end

    def operation_history(history)
      RHQ::OperationHistory::new(self,http_get(history))
    end

  end
end
