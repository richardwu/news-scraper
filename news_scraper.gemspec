# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'news_scraper/version'

Gem::Specification.new do |spec|
  spec.name          = "news_scraper"
  spec.version       = NewsScraper::VERSION
  spec.authors       = ["Richard Wu"]
  spec.email         = ["richardwu1997@gmail.com"]

  spec.summary       = 'Simple ETL news scraper in Ruby'
  spec.description   = 'A collection of extractors, transformers and loaders for a variety of news feeds and outlets.'
  spec.homepage      = 'https://github.com/richardwu/news_scraper'
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'nokogiri', '~> 1.6.8'
  spec.add_dependency 'httparty', '~> 0.14.0'
  spec.add_dependency 'sanitize', '~> 4.2.0'

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.9.0"
  spec.add_development_dependency "pry", "~> 0.10.4"
  spec.add_development_dependency "mocha", "~> 1.1.0"
  spec.add_development_dependency "timecop", "~> 0.8.0"
end
