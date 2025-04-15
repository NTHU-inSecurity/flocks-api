# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:birds].delete
  app.DB[:flocks].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:birds] = YAML.safe_load_file('db/seeds/bird_seeds.yml')
DATA[:flocks] = YAML.safe_load_file('db/seeds/flock_seeds.yml')