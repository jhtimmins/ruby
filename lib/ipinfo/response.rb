# frozen_string_literal: true
require 'json'

module IPinfo
  class Response
    # The data contained by the HTTP body of the response deserialized from
    # JSON.
    attr_reader :all

    def initialize(response)
      @all = JSON.parse(response.body, symbolize_names: true)
      response.each do |name, value|
        instance_variable_set("@#{name}", value)
        self.class.send(:attr_accessor, name)
      end
    end
  end
end
