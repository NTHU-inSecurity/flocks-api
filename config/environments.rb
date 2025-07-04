# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'sequel'
require 'logger'
require_app('lib')

require_relative '../app/lib/secure_db'
require_relative '../app/lib/auth_token'

module Flocks
  # Configuration for the API
  class Api < Roda
    plugin :environments
    # rubocop:disable Lint/ConstantDefinitionInBlock
    configure do
      # load config secrets into local environment variables (ENV)
      Figaro.application = Figaro::Application.new(
        environment: environment,
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load

      # Make the environment variables accessible to other classes
      def self.config = Figaro.env

      def self.API_HOST = config.API_HOST
      def self.GEO_KEY = config.GOOGLE_GEO_KEY

      # Connect and make the database accessible to other classes
      db_url = ENV.delete('DATABASE_URL')

      DB = Sequel.connect("#{db_url}?encoding=utf8")
      def self.DB = DB # rubocop:disable Naming/MethodName

      # Load crypto keys
      SecureDB.setup(ENV.delete('DB_KEY'))
      AuthToken.setup(ENV.fetch('MSG_KEY')) # Load crypto key
      SignedRequest.setup(ENV.delete('VERIFY_KEY'), ENV.delete('SIGNING_KEY'))

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
