require 'openssl'
require 'rhqclient'
require 'rspec/core'
require 'rspec/mocks'
require 'socket'
require 'uri'
require 'yaml'

module RHQ::RSpec

  def setup_client(options = {})
    user, password, url = config['user'], config['password'], config['url']
    @client = ::RHQ::Client.new(url, user, password, options)
  end

  def config
    @config ||= YAML.load(File.read(File.expand_path("endpoint.yml", File.dirname(__FILE__))))
  end

end

RSpec.configure do |config|
  config.include RHQ::RSpec
end
