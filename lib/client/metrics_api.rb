module RHQ
  class Client


    def metric_schedules(res_id)
      http_get("/resource/#{res_id}/schedules")
    end

    def trait_value(schedule_id)
      http_get("/metric/data/#{schedule_id}/trait")
    end

    private

  end
end
