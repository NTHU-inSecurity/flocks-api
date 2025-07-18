# frozen_string_literal: true

require 'rake/testtask'
require './require_app'

task default: [:spec]

desc 'Tests API specs only'
task :api_spec do
  sh 'ruby spec/api_spec.rb'
end

desc 'Test all the specs'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.warning = false
end

desc 'Rerun tests on live code changes'
task :respec do
  sh 'rerun -c rake spec'
end

desc 'Runs rubocop on tested code'
task style: %i[spec audit] do
  sh 'rubocop -A .'
end

desc 'Update vulnerabilities lit and audit gems'
task :audit do
  sh 'bundle audit check --update'
end

desc 'Checks for release'
task release_check: %i[spec style audit] do
  puts "\nReady for release!"
end

# Helper task for other tasks to print environment name
task :print_env do
  puts "Environment: #{ENV.fetch('RACK_ENV', nil) || 'development'}"
end

desc 'Run application console (pry)'
task console: :print_env do
  sh 'pry -r ./spec/test_load_all'
end

namespace :db do # rubocop:disable Metrics/BlockLength
  task :load do
    require_app(nil) # loads config code files only
    require 'sequel'

    Sequel.extension :migration
    @app = Flocks::Api
  end

  task load_models: [:load] do
    require_app(%w[lib models services])
  end

  desc 'Run migrations'
  task migrate: %i[load print_env] do
    puts 'Migrating database to latest'
    Sequel::Migrator.run(@app.DB, 'db/migrations')
  end

  desc 'Destroy data in database; maintain tables'
  task delete: [:load] do
    Flocks::Account.dataset.destroy
  end

  desc 'Delete dev or test database file'
  task drop: [:load] do
    if @app.environment == :production
      puts 'Cannot wipe production database!'
      return
    end

    db_filename = "db/local/#{Flocks::Api.environment}.db"
    FileUtils.rm(db_filename)
    puts "Deleted #{db_filename}"
  end

  task reset_seeds: [:load_models] do
    @app.DB[:schema_seeds].delete if @app.DB.tables.include?(:schema_seeds)
    Flocks::Account.dataset.destroy
  end

  desc 'Seeds the development database'
  task seed: [:load_models] do
    require 'sequel/extensions/seed'
    Sequel::Seed.setup(:development)
    Sequel.extension :seed
    Sequel::Seeder.apply(@app.DB, 'db/seeds')
  end

  desc 'Delete all data and reseed'
  task reseed: %i[reset_seeds seed]
end

namespace :newkey do
  task(:load_libs) { require_app('lib', config: false) }

  desc 'Create sample cryptographic key for database'
  task db: :load_libs do
    puts "DB_KEY: #{SecureDB.generate_key}"
  end

  desc 'Create sample cryptographic key for tokens and messaging'
  task msg: :load_libs do
    puts "MSG_KEY: #{AuthToken.generate_key}"
  end

  desc 'Create sample sign/verify keypair for signed communication'
  task :signing => :load_libs do
    keypair = SignedRequest.generate_keypair

    puts "SIGNING_KEY: #{keypair[:signing_key]}"
    puts " VERIFY_KEY: #{keypair[:verify_key]}"
  end
end

namespace :run do
  # Run in development mode
  desc 'Run API in development mode'
  task :dev do
    sh 'puma -p 3000'
  end
end
