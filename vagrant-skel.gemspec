# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant/skel/version'

Gem::Specification.new do |spec|
  spec.name          = 'vagrant-skel'
  spec.version       = VagrantPlugins::Skel::VERSION
  spec.authors       = ['Ignacio Galindo']
  spec.email         = ['joiggama@gmail.com']
  spec.summary       = 'Vagrant plugin for creating Vagrant environments from customized templates'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/BaxterStockman/vagrant-skel'
  spec.license       = 'MIT'

  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.files         = `git ls-files -z`.split("\x0").reject do |file|
    file.start_with?('.') or spec.test_files.include?(file)
  end

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',  '~> 1.12.5'
  spec.add_development_dependency 'rake',     '~> 10.0'
  spec.add_development_dependency 'rspec',    '~> 2.14.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'cane'
  spec.add_development_dependency 'coveralls'
end
