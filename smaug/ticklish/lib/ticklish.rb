module Ticklish
  class Registry
    attr_reader :registry

    def self.mount *services
      inst = new
      inst.register *services
      inst
    end

    def initialize
      @registry = []
    end

    def register *services
      registry.concat services
    end

    def tick(args)
      registry.each {| service | service.tick(args)}
    end
  end
end