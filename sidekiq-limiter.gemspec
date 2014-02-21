# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq/limiter/version'

Gem::Specification.new do |spec|
  spec.name          = 'sidekiq-limiter'
  spec.version       = Sidekiq::Limiter::VERSION
  spec.authors       = ['Max Kazarin']
  spec.email         = ['maxkazargm@gmail.com']
  spec.summary       = %q{Sidekiq job limiter per instance.}
  spec.description   = %q{Limit sidekiq worker with one job per instance in queue.}
  spec.homepage      = 'https://github.com/maxkazar/sidekiq-limiter'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
end
