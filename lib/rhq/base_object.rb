module RHQ
  class BaseObject
    attr_reader :client, :json, :id

    def initialize(client, json)
      @client = client
      @json = json
      self
    end

    protected

      def link(js,rel)
        if js.has_key?("links")
          links = js["links"].select {|link| link.has_key?(rel)}
          if !links.empty?
            return links[0][rel]["href"]
          end
        end
      end
  end
end
