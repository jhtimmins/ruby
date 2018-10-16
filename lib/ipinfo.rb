# frozen_string_literal: true

require 'cgi'
require 'ipinfo/adapter'
require 'ipinfo/cache/default_cache'
require 'ipinfo/errors'
require 'ipinfo/response'
require "ipinfo/version"

module IPinfo
  DEFAULT_CACHE_MAXSIZE = 4096
  DEFAULT_CACHE_TTL = 60 * 60 * 24
  RATE_LIMIT_MESSAGE = "To increase your limits, please review our paid plans at https://ipinfo.io/pricing"

  class << self
    def getHandler(access_token=nil, settings={})
      IPinfo.new(access_token, settings)
    end
  end

  class IPinfo
    attr_accessor :access_token

    def initialize(access_token=nil, settings={})
      @access_token = access_token
      @http_client = getHttpClient(settings.fetch("http_client", nil))

      maxsize = settings.fetch("maxsize", DEFAULT_CACHE_MAXSIZE)
      ttl = settings.fetch("ttl", DEFAULT_CACHE_TTL)
      @cache = settings.fetch("cache", DefaultCache.new(ttl, maxsize))
    end

    def getDetails(ip_address=nil)
      details = getRequestDetails(ip_address)
      Response.new(details)
    end

    protected
    def getRequestDetails(ip_address=nil)

      if !@cache.contains(ip_address)
        response = @http_client.get(escape_path(ip_address))

        raise RateLimitError.new(RATE_LIMIT_MESSAGE) if response.status.eql?(429)

        details = JSON.parse(response.body, symbolize_names: true)
        @cache.set(ip_address, details)
      end

      @cache.get(ip_address)
    end

    def getHttpClient(http_client=nil)

      if http_client
        @http_client = Adapter.new(access_token, http_client)
      else
        @http_client = Adapter.new(access_token)
      end

    end

    private
    def escape_path(ip)
      ip ? "/#{CGI::escape(ip)}" : '/'
    end
  end
end
