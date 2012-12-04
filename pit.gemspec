# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pit/version'

Gem::Specification.new do |gem|
  gem.name          = "pit"
  gem.version       = Pit::VERSION
  gem.authors       = ["cho45"]
  gem.email         = ["cho45@lowreal.net"]
  gem.description   = %q|pit: account management tool|
  gem.summary       = %q|pit: account management tool|
  gem.homepage      = "http://github.com/cho45/pit"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
