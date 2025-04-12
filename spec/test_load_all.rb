# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require 'fileutils'

secrets_path = 'config/secrets.yml'
unless File.exist?(secrets_path)
  puts "create #{secrets_path} from example file"
  FileUtils.cp("#{secrets_path.sub('.yml', '')}_example.yml", secrets_path)
end

FileUtils.mkdir_p('db/local')

require_relative '../require_app'
require_app

def wipe_database
  app.DB[:birds].delete if app.DB.tables.include?(:birds)
  app.DB[:flocks].delete if app.DB.tables.include?(:flocks)
end

def app
  Flocks::Api
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:documents] = YAML.safe_load_file('db/seeds/bird_seeds.yml') rescue []
DATA[:projects] = YAML.safe_load_file('db/seeds/flock_seeds.yml') rescue []

DATA[:flocks] = [
  {
    'destination_url' => 'https://maps.app.goo.gl/example1',
    'birds' => [
      {
        'username' => 'testuser1',
        'message' => 'test message 1',
        'latitude' => 24.7,
        'longitude' => 121.0,
        'estimated_time' => 1200
      }
    ]
  },
  {
    'destination_url' => 'https://maps.app.goo.gl/example2',
    'birds' => [
      {
        'username' => 'testuser2',
        'message' => 'test message 2',
        'latitude' => 24.8,
        'longitude' => 121.1,
        'estimated_time' => 600
      }
    ]
  }
]