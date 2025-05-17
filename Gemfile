# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# WEB API
gem 'base64'
gem 'json'
gem 'logger', '~>1.0'
gem 'puma', '~>6.0'
gem 'roda', '~>3.0'

# CONFIGURATION
gem 'figaro', '~>1.2'
gem 'rake'

# SECURITY
gem 'rbnacl', '~>7.0'

# DATABASE
gem 'hirb'
gem 'sequel', '~>5.55'

# WEB SOCKETS
gem 'faye', '~> 1'

# Debugging
gem 'pry'

# Development
group :development do
  gem 'rerun'

  # Quality
  gem 'rubocop'
  gem 'rubocop-minitest'
  gem 'rubocop-performance'
  gem 'rubocop-rake'
  gem 'rubocop-sequel'

  # Audit
  gem 'bundler-audit'
end

group :development, :test do
  # API testing
  gem 'rack-test'

  # Database
  gem 'sequel-seed'
  gem 'sqlite3', '~>1.6'
end

group :production do
  gem 'pg'
end

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
end
