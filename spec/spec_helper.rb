# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require 'rack/test'

require_relative 'test_load_all'

def app
  Flocks::App
end

def wipe_database
  app.DB[:birds].delete
  app.DB[:flocks].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:birds] = YAML.safe_load_file('db/seeds/bird_seeds.yml')
DATA[:flocks] = YAML.safe_load_file('db/seeds/flock_seeds.yml')

unless app.config.API_HOST
  app.configure :test do
    app.config.API_HOST = 'http://localhost:9090'
  end
end

raise 'Seed data unavailable: flocks' if DATA[:flocks].empty?
raise 'Seed data unavailable: birds' if DATA[:birds].empty?