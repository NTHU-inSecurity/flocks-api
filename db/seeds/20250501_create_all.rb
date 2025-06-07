# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts and flocks'
    create_accounts
    create_flocks
  end
end

require 'yaml'

DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/account_seeds.yml")
FLOCK_INFO = YAML.load_file("#{DIR}/flock_seeds.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Flocks::Account.create(
      username: account_info['username'],
      password: account_info['password']
    )
  end
end

def create_flocks
  ACCOUNTS_INFO.zip(FLOCK_INFO).each_key do |account_data|
    account_data['username']
  end
end
