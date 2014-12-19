module RHQ
  class Client
    def discovery_queue
      resources({:status => "NEW"})
    end

    def import(res_array=nil)
      if res_array.nil?
        # import all .. but platforms first
        import_resources(resources({:status => "NEW", :category => "PLATFORM"}))
        import_resources(resources({:status => "NEW"}))
      else
        print import_resources(res_array)
      end
    end
    
    def platforms(opts={})
      resources(opts.merge({:status => "COMMITTED",:category => "PLATFORM"}))
    end
    
    def resources(opts={}, &block)      
      filter = URI.encode_www_form(opts)
      http_get("/resource?"+filter).map do |r|
        RHQ::Resource::new(self,r)
      end
    end

    private
      def import_resources(res_array)
        res_array.each do |r|
          r.json["status"] = "COMMITTED"
          http_put("/resource/%s" % r.id,r.json)
        end
      end

  end
end
