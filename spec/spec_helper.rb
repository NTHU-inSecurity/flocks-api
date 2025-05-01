# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  Flocks::Bird.map(&:destroy)
  Flocks::Flock.map(&:destroy)
  Flocks::Account.map(&:destroy)
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:birds] = YAML.safe_load_file('db/seeds/bird_seeds.yml')
DATA[:flocks] = YAML.safe_load_file('db/seeds/flock_seeds.yml')
DATA[:accounts] = YAML.safe_load_file('db/seeds/account_seeds.yml')
