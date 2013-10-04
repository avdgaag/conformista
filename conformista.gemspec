# -*- encoding: utf-8 -*-
require File.expand_path('../lib/conformista/version', __FILE__)

Gem::Specification.new do |s|
  # Metadata
  s.name        = 'conformista'
  s.version     = Conformista::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Arjan van der Gaag']
  s.email       = %q{arjan@arjanvandergaag.nl}
  s.description = %q{A library for creating form objects for Rails applications.}
  s.homepage    = %q{http://avdgaag.github.com/conformista}
  s.summary     = <<-EOS
Conformista is a library to make building presenters -- and form objects in
particular -- easier. It provides an ActiveModel-compliant base class that your
own form objects can inherit from, along with standard behaviour for creating,
loading, validating and persisting business objects (usually ActiveRecord
models).
EOS

  # Files
  s.files         = `git ls-files`.split("
")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("
")
  s.executables   = `git ls-files -- bin/*`.split("
").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Rdoc
  s.rdoc_options = ['--charset=UTF-8']
  s.extra_rdoc_files = [
     'LICENSE',
     'README.md',
     'HISTORY.md'
  ]

  # Dependencies
  s.add_dependency 'activemodel'
  s.add_development_dependency 'kramdown'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'sqlite3'
end
