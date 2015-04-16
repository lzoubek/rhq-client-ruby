module RHQ
  class Client
    def resource_alert_definitions(resource_id)
      http_get("/alert/definitions?resourceId=#{resource_id}")
    end

    def alert_definition(ad_id)
      http_get("/alert/definition/#{ad_id}")
    end

    def alert_definition_create(resource_id, alert_body)
      http_post("/alert/definitions/?resourceId=#{resource_id}",alert_body)
    end

    def alert_definition_remove(ad_id)
      http_delete("/alert/definition/#{ad_id}")
    end

    def alert_ack(alert_id)
      http_put("/alert/#{alert_id}", {})
    end

    def alert(id)
      RHQ::Alert::new(self, http_get("/alert/#{id}"))
    end
    def resource_alerts(resource_id,opts={})
      filter = URI.encode_www_form({:resourceId => resource_id, :slim => true, :unacknowledgedOnly => true}.merge(opts))
      http_get("/alert?"+filter).map do |a|
        RHQ::Alert::new(self,a)
      end
    end

  end
end
