require 'ipaddr'
require 'json'

module IPinfo
  class Response
    # The data contained by the HTTP body of the response deserialized from
    # JSON.
    attr_reader :all

    def initialize(response)
      @all = response

      @all.each do |name, value|
        instance_variable_set("@#{name}", value)
        self.class.send(:attr_accessor, name)
      end

      if response.has_key?(:ip)
        instance_variable_set(@ip_address, IPAddr.new(response[:ip])))
        self.class.send(:attr_accessor, 'ip_address')
      end
    end
  end
end
