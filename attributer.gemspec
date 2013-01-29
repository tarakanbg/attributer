# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'attributer/version'

Gem::Specification.new do |gem|
  gem.name          = "attributer"
  gem.version       = Attributer::VERSION
  gem.authors       = ["Svilen Vassilev"]
  gem.email         = ["svilen@rubystudio.net"]
  gem.description   = %q{Ruby gem for adding width and height attributes to image tags within HTML blocks}
  gem.summary       = %q{Ruby gem for adding width and height attributes to image tags within HTML blocks}
  gem.homepage      = "https://github.com/tarakanbg/attributer"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "guard"
  gem.add_development_dependency "libnotify"
  gem.add_development_dependency "guard-rspec"
  gem.add_dependency "fastimage", "~> 1.2.13"
  gem.add_dependency "nokogiri", "~> 1.5.6"
end
