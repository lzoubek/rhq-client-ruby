require "rhq/base_object"
require "rhq/version"
require "rhq/resource"
require "rhq/resource_types"
require "rhq/operation"
require "rhq/alert"

require "client/resource_api"
require "client/operation_api"
require "client/status_api"
require "client/metrics_api"
require "client/alert_api"

require "json"
require "rest_client"
require "restclient_ext/request"

module RHQ

  class RhqException < StandardError
    def initialize(message)
      @message = message
      super
    end

    def message
      @message
    end
  end

  class Client

    attr_reader :credentials, :entrypoint, :options

    # Construct a new RHQ client class.
    # optional parameters
    #   entrypoint, username, password
    #
    def initialize(entrypoint='http://localhost:7080/rest',username='rhqadmin', password='rhqadmin', options={})
      @entrypoint = entrypoint
      @credentials = { :username => username, :password => password }
      @options = {
        :poll_delay => 0.2,
        :resource_filter => { # default filter options whenever querying /resource endpoint
          :status => "COMMITTED", # by default we're interested in committed = managed resources only
          :ps => 999, # this client does not care about paging
          :strict => true # be strict when filtering by anything
        }
      }.merge(options)
    end

    def http_get(suburl, headers={})
      begin
        res = rest_client(suburl).get(http_headers(headers))
        puts "#{res}\n" if ENV['RHQCLIENT_LOG_RESPONSE']
        JSON.parse(res)
      rescue
        handle_fault $!
      end
    end

    def http_post(suburl, hash, headers={})
      begin
        body = JSON.generate(hash)
        res = rest_client(suburl).post(body, http_headers(headers))
        puts "#{res}\n" if ENV['RHQCLIENT_LOG_RESPONSE']
        JSON.parse(res)
      rescue
        handle_fault $!
      end
    end

    def http_put(suburl, hash, headers={})
      begin
        body = JSON.generate(hash)
        res = rest_client(suburl).put(body, http_headers(headers))
        puts "#{res}\n" if ENV['RHQCLIENT_LOG_RESPONSE']
        JSON.parse(res)
      rescue
        handle_fault $!
      end
    end

    def http_delete(suburl, headers={})
      begin
        res = rest_client(suburl).delete(http_headers(headers))
        puts "#{res}\n" if ENV['RHQCLIENT_LOG_RESPONSE']
        #JSON.parse(res)
      rescue
        handle_fault $!
      end
    end

    def auth_header
      # This is the method for strict_encode64:
      encoded_credentials = ["#{@credentials[:username]}:#{@credentials[:password]}"].pack("m0").gsub(/\n/,'')
      { :authorization => "Basic " + encoded_credentials }
    end

    def rest_client(suburl)
      if (URI.parse(@entrypoint)).scheme == 'https'
        options = {}
        options[:verify_ssl] = ca_no_verify ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
        options[:ssl_cert_store] = ca_cert_store if ca_cert_store
        options[:ssl_ca_file] = ca_cert_file if ca_cert_file
      end
      options[:timeout] = ENV['RHQCLIENT_REST_TIMEOUT'] if ENV['RHQCLIENT_REST_TIMEOUT']
      # strip @endpoint in case suburl is absolute
      if suburl.match(/^http/)
        suburl = suburl[@entrypoint.length,suburl.length]
      end
      RestClient::Resource.new(@entrypoint, options)[suburl]
    end

    def base_url
      url = URI.parse(@entrypoint)
      "#{url.scheme}://#{url.host}:#{url.port}"
    end

    def self.parse_response(response)
      JSON.parse(response)
    end

    def http_headers(headers ={})
      {}.merge(auth_header).merge({
        :content_type => 'application/json',
        :accept => 'application/json',
      }).merge(headers)
    end

    def handle_fault(f)
      fault = "#{f.message}\n%s\n" % JSON.parse(f.http_body)["message"] rescue
      fault ||= f.message
      raise RhqException::new(fault)
    end
  end

end
