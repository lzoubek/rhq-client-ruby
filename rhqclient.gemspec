# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rhq/version'

Gem::Specification.new do |gem|
  gem.name          = "rhq-client"
  gem.version       = RHQ::VERSION
  gem.authors       = ['Libor Zoubek']
  gem.email         = ['lzoubek@redhat.com']
  gem.homepage      = "http://github.com/rhq/rhq-client-ruby"
  gem.summary       = %q{A Ruby client for RHQ EST API}
  gem.description   = <<-EOS
    A Ruby client for RHQ REST API
  EOS

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency('rest-client')
  gem.add_development_dependency('shoulda')
  gem.add_development_dependency('rspec-rails', '~> 2.6')
  gem.add_development_dependency('rake')

  gem.rdoc_options << '--title' << gem.name << '--main' << 'README.rdoc' << '--line-numbers' << '--inline-source'
  gem.extra_rdoc_files = ['README.rdoc', 'CHANGES.rdoc']
end
