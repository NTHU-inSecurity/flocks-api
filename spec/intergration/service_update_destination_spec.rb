# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test UpdateDestination Service' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:accounts].each do |account_info|
      Flocks::Account.create(account_info)
    end

    @accounts = Flocks::Account.all
    @flock = Flocks::CreateFlock.call(username: @accounts[0].username, flock_data: DATA[:flocks][0])
    data = DATA[:birds].zip(@accounts).map { |bird_data, account| bird_data.merge({ account: account }) }
    data.each { |d| Flocks::AddBirdToFlock.call(flock_id: @flock.id, bird_data: d) }
  end

  it 'HAPPY: should be able to update destination' do
    Flocks::UpdateDestination.call(
      username: @accounts[0].username,
      flock_id: Flocks::Flock.first.id,
      new_destination: 'https://new-destination.com'
    )

    flock = Flocks::Flock.first

    _(flock.destination_url).must_equal 'https://new-destination.com'
  end

  it 'BAD: should return error if visitor attempts to update destination' do
    _(proc {
      Flocks::UpdateDestination.call(
        username: @accounts[1].username,
        flock_id: Flocks::Flock.first.id,
        new_destination: 'https://new-destination.com'
      )
    }).must_raise Flocks::UpdateDestination::UnauthorizedError
  end
end
