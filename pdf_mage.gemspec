# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pdf_mage/version'

Gem::Specification.new do |spec|
  spec.name               = 'pdf_mage'
  spec.version            = PdfMage::VERSION
  spec.authors            = %w[Jeremy Haile Dean Papastrat]
  spec.email              = %w[jeremy@sideqik.com dean@sideqik.com]
  spec.summary            = 'A lightweight Ruby gem for rendering PDFs with Chrome Headless'
  spec.homepage           = 'https://github.com/sideqik/pdf-mage'
  spec.license            = 'MIT'
  spec.executables        = %w[pdf_mage]
  spec.require_paths      = %w[lib]
  spec.bindir             = 'bin'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.add_dependency 'aws-sdk-s3', '~> 1'
  spec.add_dependency 'redis', '~> 4.0'
  spec.add_dependency 'sidekiq', '~> 5.1'
  spec.add_dependency 'sinatra', '~> 2.0'
  spec.add_dependency 'typhoeus', '~> 1.1'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'coveralls', '~> 0.8'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rubocop', '~> 0.56'
end
