# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'sequel'
require 'logger'

require_relative '../app/lib/secure_db'

module Flocks
  # Configuration for the API
  class Api < Roda
    plugin :environments
    # rubocop:disable Lint/ConstantDefinitionInBlock
    configure do
      # load config secrets into local environment variables (ENV)
      Figaro.application = Figaro::Application.new(
        environment: environment,
        path: File.expand_path('config/secrets_example.yml')
      )
      Figaro.load

      # Make the environment variables accessible to other classes
      def self.config = Figaro.env

      # Connect and make the database accessible to other classes
      db_url = ENV.delete('DATABASE_URL') 
      db_path = case environment
      when 'test'
        'sqlite://db/local/test.db'
      when 'development'
        'sqlite://db/local/development.db'
      else
        'sqlite://db/local/production.db'
      end

      DB = Sequel.connect(db_url || db_path, encoding: 'utf8')
      def self.DB = DB # rubocop:disable Naming/MethodName

      # Load crypto keys
      SecureDB.setup(ENV.delete('DB_KEY'), ENV.delete('TICKET_SALT'))

      # Custom events logging
      LOGGER = Logger.new($stderr)
      def self.logger = LOGGER
    end
    # rubocop:enable Lint/ConstantDefinitionInBlock

    # HTTP Request logging
    configure :development, :production do
      plugin :common_logger, $stdout
    end

    configure :development, :test do
      require 'pry'
    end

    configure :test do
      logger.level = Logger::ERROR
    end
  end
end
