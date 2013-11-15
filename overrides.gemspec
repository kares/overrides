# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'overrides/version'

Gem::Specification.new do |gem|
  gem.name          = "overrides"
  gem.version       = Overrides::VERSION
  gem.authors       = ["Karol Bucek"]
  gem.email         = ["self@kares.org"]
  gem.summary       = %q{an #overrides annotation for your methods}
  gem.description   = %q{An #overrides annotation for your (Ruby) methods.}
  gem.homepage      = "http://github.com/kares/overrides"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "minitest", "~> 3.0"
  gem.add_development_dependency "bundler", "~> 1.3"
  gem.add_development_dependency "rake", "~> 10.1"
end
