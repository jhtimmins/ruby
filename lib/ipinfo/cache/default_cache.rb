require 'ipinfo/cache/cache_interface'
require 'lrucache'

module IPinfo
  class DefaultCache < CacheInterface

    DEFAULT_TTL = 60 * 60 * 24
    DEFAULT_MAXSIZE = 4096

    def initialize(ttl=DEFAULT_TTL, maxsize=DEFAULT_MAXSIZE)
      @cache = LRUCache.new(:ttl=ttl.seconds, :maxsize=maxsize)
    end

    def get(key)
      @cache[:key]
    end

    def set(key, value))
      @cache[:key] = value
    end

    def contains(key)
      !@cache[:key].nil?
    end
  end
end
