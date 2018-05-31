lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pdf_mage/version'

Gem::Specification.new do |spec|
  spec.name               = 'pdf_mage'
  spec.version            = PdfMage::VERSION
  spec.authors            = ['Jeremy Haile', 'Dean Papastrat']
  spec.email              = ['jeremy@sideqik.com', 'dean@sideqik.com']
  spec.summary            = %q{A lightweight Ruby gem for rendering PDFs with Chrome Headless}
  spec.homepage           = 'https://github.com/sideqik/pdf-mage'
  spec.license            = 'MIT'
  spec.executables        = ['pdf_mage']
  spec.require_paths      = ['lib']
  spec.bindir             = 'bin'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.add_dependency 'god', '~> 0.13.6'
  spec.add_dependency 'sinatra', '~> 2.0'
  spec.add_dependency 'sidekiq', '~> 5.1'
  spec.add_dependency 'sinatra', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
end
