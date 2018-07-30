# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spi/version'

Gem::Specification.new do |spec|
  spec.name          = "spi"
  spec.version       = SPI::VERSION
  spec.authors       = ["Mike Axford"]
  spec.email         = ["mike@m1ari.co.uk"]

  spec.summary       = %q{SPI access library }
  spec.description   = %q{Module for configuring and communicating with devices on an SPI device, useful for various Small Board Computers such as RaspberryPi and C.H.I.P.}
  spec.homepage      = "https://github.com/m1ari/ruby-spi"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler" #, "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
end
