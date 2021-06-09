# encoding: UTF-8
Gem::Specification.new do |gem|
  gem.authors       = ["Personal Wine"]
  gem.email         = ["dev@personalwine.com"]
  gem.summary       = "Webhooks and Push API implemention for Flowlink"
  gem.description   = gem.summary
  gem.homepage      = "http://flowlink.io"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "solidus_flowlink"
  gem.require_paths = ["lib"]
  gem.version       = '0.0.0'

  gem.add_dependency 'solidus_core', '~> 2.0'
  gem.add_dependency 'solidus_api', '~> 2.0'
  gem.add_dependency 'active_model_serializers', '~> 0.9.0'
  gem.add_dependency 'httparty'

  gem.add_development_dependency 'capybara', '~> 2.1'
  gem.add_development_dependency 'coffee-rails', '~> 5.0.0'
  gem.add_development_dependency 'database_cleaner-active_record', '2.0.0'
  gem.add_development_dependency 'factory_girl', '~> 4.4'
  gem.add_development_dependency 'ffaker'
  gem.add_development_dependency 'mysql2'
  gem.add_development_dependency 'pg'
  gem.add_development_dependency 'rspec-rails', '~> 3.8'
  gem.add_development_dependency 'sass-rails', '~> 5.0.0'
  gem.add_development_dependency 'selenium-webdriver'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'timecop'
end
