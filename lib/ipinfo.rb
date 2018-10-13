# frozen_string_literal: true

require "ipinfo/version"
require 'ipinfo/errors'
require 'ipinfo/response'
require 'ipinfo/adapter'
require 'cgi'

module IPinfo
  RATE_LIMIT_MESSAGE = "To increase your limits, please review our paid plans at https://ipinfo.io/pricing"

  class << self
    attr_accessor :access_token

    def initialize(access_token=nil, settings={})
      @access_token = access_token
      @http_client = getHttpClient(settings.fetch("http_client", nil))
      @cache = getCache(settings.fetch("cache", nil))
    end

    def getDetails(ip_address=nil)
      details = requestDetails(ip_address)
    end

    protected
    def requestDetails(ip_address=nil)
      # if not in cache
      response = @http_client.get(escape_path(ip_address))

      raise RateLimitError.new(RATE_LIMIT_MESSAGE) if response.status.eql?(429)

      Response.from_faraday(response)

      #save to cache

      #return value from cache

    end

    def getHttpClient(http_client=nil)

      if client_name
        @http_client = Adapter.new(access_token, http_client)
      else
        @http_client = Adapter.new(access_token)
      end

    end

    # def getCache(cache=nil)
    #
    # end

    private

    def escape_path(ip)
      ip ? "/#{CGI::escape(ip)}" : '/'
    end
  end
end
