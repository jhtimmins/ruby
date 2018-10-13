# frozen_string_literal: true
require 'test_helper'

class IPinfoTest < Minitest::Test
  IP4 = '195.233.174.116'
  IP6 = '2601:9:7680:363:75df:f491:6f85:352f'

  def test_that_it_has_a_version_number
    refute_nil ::IPinfo::VERSION
  end

  def test_set_adapter
    assert IPinfo.http_adapter = :excon
    IPinfo.http_adapter = nil
  end

  def test_set_access_token
    assert IPinfo.access_token = 'test_token'

    VCR.use_cassette('lookup_with_token') do
      IPinfo.lookup
      assert_requested :get, "https://ipinfo.io?token=test_token"
    end

    IPinfo.access_token = nil
  end

  def test_rate_limit_error
    stub_request(:get, 'https://ipinfo.io').to_return(body:'', status: 429)
    error = assert_raises(IPinfo::RateLimitError) { IPinfo.lookup }
    assert_equal "To increase your limits, please review our paid plans at https://ipinfo.io/pricing", error.message
  end

  def test_lookup_without_arg
    expected = {
      ip: "110.171.151.183",
      hostname: "cm-110-171-151-183.revip7.asianet.co.th",
      city: "Chiang Mai",
      region: "Chiang Mai Province",
      country: "TH",
      loc: "18.7904,98.9847",
      org: "AS17552 TRUE INTERNET CO., LTD.",
      postal: "50000"
    }

    VCR.use_cassette('current machine search') do
      IPinfo.lookup.tap do |resp|
        assert_instance_of IPinfo::Response, resp
        assert_equal expected, resp.data
        assert_equal 200, resp.status
      end
    end
  end

  def test_lookup_ip6
    expected = {
      ip: "2601:9:7680:363:75df:f491:6f85:352f",
      city: "",
      region: "",
      country: "US",
      loc: "37.7510,-97.8220",
      org: "AS7922 Comcast Cable Communications, LLC"
    }

    VCR.use_cassette('search with ip6') do
      assert_equal expected, IPinfo.lookup(IP6).data
    end
  end

  def test_lookup_ip4
    expected = {
      ip: IP4,
      city: "",
      region: "",
      country: "DE",
      loc: "51.2993,9.4910",
      org: "AS12663 Vodafone Italia S.p.A."
    }

    VCR.use_cassette('search with random ip') do
      assert_equal expected, IPinfo.lookup(IP4).data
    end
  end
end
