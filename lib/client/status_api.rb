module RHQ
  class Client
    def status
      response = http_get("/status")
      response.values[0]
    end
  end
end
