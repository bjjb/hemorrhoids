# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'hemorrhoids/version'

Gem::Specification.new do |gem|
  gem.name          = "hemorrhoids"
  gem.version       = Hemorrhoids::VERSION
  gem.authors       = ["JJ Buckley"]
  gem.email         = ["jjbuckley@gmail.com"]
  gem.description   = %q{Hemorrhoids is a Ruby library for extracting a tree of related records from an ActiveRecord database, so you can take smaller dumps.}
  gem.summary       = %q{Hemorrhoids restrict (database) dumps (using ActiveRecord)}
  gem.homepage      = "http://github.com/jjbuckley/hemorrhoids"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^test/})
  gem.require_paths = ["lib"]
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "rack-test"
  gem.add_development_dependency "guard"
end
