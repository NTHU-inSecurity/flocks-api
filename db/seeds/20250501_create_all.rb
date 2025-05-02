# frozen_string_literal: true

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, flocks, birds'
    create_accounts
    create_flock
    add_bird_to_flock
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/account_seeds.yml")
FLOCK_INFO = YAML.load_file("#{DIR}/flock_seeds.yml")
BIRD_INFO = YAML.load_file("#{DIR}/bird_seeds.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    Flocks::Account.create(account_info)
  end
end

def create_flock
  Flocks::CreateFlock.call(
    email: ACCOUNTS_INFO[0]['email'], flock_data: FLOCK_INFO[0]
  )
  # ACCOUNTS_INFO.zip(FLOCK_INFO).each do |account_data, flock_data|
  #    Flocks::CreateFlock.call(
  #      email: account_data['email'], flock_data: flock_data
  #    )
  # end
end

def add_bird_to_flock
  accounts = Flocks::Account.all
  data = BIRD_INFO.zip(accounts).map { |bird_data, account| bird_data.merge({ account: account }) }
  bird_info_each = data.each
  flock_cycle = Flocks::Flock.all.cycle
  loop do
    bird_info = bird_info_each.next
    flock = flock_cycle.next
    Flocks::AddBirdToFlock.call(
      flock_id: flock.id, bird_data: bird_info
    )
  end
end
