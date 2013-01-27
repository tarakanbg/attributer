# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'attributer/version'

Gem::Specification.new do |gem|
  gem.name          = "attributer"
  gem.version       = Attributer::VERSION
  gem.authors       = ["Svilen Vassilev"]
  gem.email         = ["svilen@rubystudio.net"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "guard"
  gem.add_development_dependency "libnotify"
  gem.add_development_dependency "guard-rspec"
  # gem.add_dependency "curb", "~> 0.8.3"
  # gem.add_dependency "time_diff", "~> 0.3.0"
  # gem.add_dependency "gcmapper", "~> 0.3.1"
end
