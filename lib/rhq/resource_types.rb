module RHQ
  class Platform < Resource

    def initialize(resource)
      super(resource.client,resource.json)
      self
    end

    def servers(opts={})
      children(opts.merge({:category => "SERVER"}))
    end

    def servers_as7_standalone(opts={})
      children(opts.merge({:plugin => "JBossAS7", :type => "JBossAS7 Standalone Server"}))
    end
  end
end
