# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, flocks, birds'
    create_accounts
    create_flocks
  end
end

require 'yaml'
require_relative '../../app/services/create_flock'
require_relative '../../app/services/add_bird_to_flock'

DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/account_seeds.yml")
FLOCK_INFO = YAML.load_file("#{DIR}/flock_seeds.yml")
BIRD_INFO = YAML.load_file("#{DIR}/bird_seeds.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Flocks::Account.create(username: account_info['username'], password: account_info['password'])
  end
end

def create_flocks
  ACCOUNTS_INFO.zip(FLOCK_INFO, BIRD_INFO).each do |account_data, flock_data, bird_data|
    username = account_data['username']

    # Build combined flock_data with optional bird values
    full_flock_data = {
      destination_url: flock_data['destination_url'],
      latitude: bird_data['latitude'].to_s,
      longitude: bird_data['longitude'].to_s,
      message: bird_data['message']
    }

    Flocks::CreateFlock.call(username: username, flock_data: full_flock_data)
  end
end