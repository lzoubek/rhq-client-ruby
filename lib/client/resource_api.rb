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
        import_resources(res_array)
      end
    end

    def platforms(opts={})
      resources(opts.merge({:category => "PLATFORM"})).map { |p|
        RHQ::Platform::new(p)
      }
    end

    def resource_children(res_id, opts={})
      resources_search(opts.merge({:parentId => res_id}))
    end

    def resources_search(opts={})
      filter = URI.encode_www_form(@options[:resource_filter].merge(opts))
      http_get("/resource/search?"+filter).map do |r|
        RHQ::Resource::new(self,r)
      end
    end

    def resources(opts={})
      filter = URI.encode_www_form(@options[:resource_filter].merge(opts))
      http_get("/resource?"+filter).map do |r|
        RHQ::Resource::new(self,r)
      end
    end

    def resource(id)
      RHQ::Resource::new(self,http_get("/resource/#{id}"))
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
