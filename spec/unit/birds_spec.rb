# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Bird Handling' do
  before do
    wipe_database

    # Seed accounts
    DATA[:accounts].each { |account_info| Flocks::Account.create(account_info) }

    # Create flock with real bird data from seed
    @creator = Flocks::Account.first
    @flock = Flocks::CreateFlock.call(
      username: @creator.username,
      flock_data: {
        destination_url: DATA[:flocks][0]['destination_url'],
        message: DATA[:birds][0]['message'],
        latitude: DATA[:birds][0]['latitude'],
        longitude: DATA[:birds][0]['longitude']
      }
    )
  end

  it 'HAPPY: should retrieve correct data from database' do
    created_bird = @flock.birds.first
    bird_data = DATA[:birds][0]

    _(created_bird.message).must_equal bird_data['message']
    _(created_bird.longitude).must_be_close_to bird_data['longitude'].to_f, 0.0001
    _(created_bird.latitude).must_be_close_to bird_data['latitude'].to_f, 0.0001
  end

  it 'SECURITY: should not use deterministic integers' do
    second_account = Flocks::Account.where(username: DATA[:accounts][1]['username']).first
    bird_data = DATA[:birds][1].transform_keys(&:to_sym).merge(account_id: second_account.id)
    new_bird = Flocks::AddBirdToFlock.call(flock_id: @flock.id, bird_data: bird_data)

    _(new_bird.account_id.is_a?(Numeric)).must_equal false
    _(new_bird.flock_id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    third_account = Flocks::Account.where(username: DATA[:accounts][2]['username']).first
    bird_data = DATA[:birds][2].transform_keys(&:to_sym).merge(account_id: third_account.id)
    new_bird = Flocks::AddBirdToFlock.call(flock_id: @flock.id, bird_data: bird_data)

    raw = app.DB[:birds].where(id: new_bird.id).first

    _(raw[:message_secure]).wont_equal new_bird.message
    _(raw[:latitude_secure]).wont_equal new_bird.latitude
    _(raw[:longitude_secure]).wont_equal new_bird.longitude
  end
end
