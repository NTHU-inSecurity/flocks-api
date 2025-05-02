# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Bird Handling' do
  before do
    wipe_database

    DATA[:accounts].each do |account_info|
      Flocks::Account.create(account_info)
    end

    Flocks::CreateFlock.call(email: DATA[:accounts][0]['email'], flock_data: DATA[:flocks][0])
  end

  it 'HAPPY: should retrieve correct data from database' do
    flock = Flocks::Flock.first
    bird_data = DATA[:birds][0].merge({ account: Flocks::Account.first })
    new_bird = Flocks::AddBirdToFlock.call(flock_id: flock.id, bird_data: bird_data)

    bird = Flocks::Bird.find(id: new_bird.id)
    _(bird.username).must_equal bird_data['username']
    _(bird.message).must_equal bird_data['message']
    _(bird.longitude).must_equal bird_data['longitude']
    _(bird.latitude).must_equal bird_data['latitude']
  end

  it 'SECURITY: should not use deterministic integers' do
    flock = Flocks::Flock.first
    bird_data = DATA[:birds][0].merge({ account: Flocks::Account.first })
    new_bird = Flocks::AddBirdToFlock.call(flock_id: flock.id, bird_data: bird_data)

    _(new_bird.account_id.is_a?(Numeric)).must_equal false
    _(new_bird.flock_id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    flock = Flocks::Flock.first
    bird_data = DATA[:birds][0].merge({ account: Flocks::Account.first })
    new_bird = Flocks::AddBirdToFlock.call(flock_id: flock.id, bird_data: bird_data)

    stored_bird = app.DB[:birds].first

    _(stored_bird[:message_secure]).wont_equal new_bird.message
    _(stored_bird[:latitude_secure]).wont_equal new_bird.latitude
    _(stored_bird[:longitude_secure]).wont_equal new_bird.longitude
  end
end
