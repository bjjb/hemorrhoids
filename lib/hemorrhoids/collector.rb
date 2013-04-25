require 'hemorrhoids'
module Hemorrhoids
  class Collector
    attr_writer :ready

    def initialize
      @cache = {}
      @ready = false
    end

    def ready?
      @ready
    end

    def collect(hemorrhoid)
      @cache[hemorrhoid.key] ||= Set.new
      @cache[hemorrhoid.key].merge(hemorrhoid.ids)
      hemorrhoid.hemorrhoids.each do |hemorrhoid|
        @cache[hemorrhoid.key].merge(hemorrhoid.ids)
      end
      @ready = true
    end
  end
end
