# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hiera/backend/trocla/version'

Gem::Specification.new do |spec|
  spec.name          = "hiera-backend-trocla"
  spec.version       = Hiera::Backend::Trocla::VERSION
  spec.authors       = ["Andreas Zuber"]
  spec.email         = ["zuber@puzzle.ch"]
  spec.description   = %q{This is a hiera backend for the trocla password storage tool}
  spec.summary       = %q{This is a hiera backend for the trocla password storage tool}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "hiera"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"

  spec.add_dependency "trocla"
end
