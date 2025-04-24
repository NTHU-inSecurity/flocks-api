# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Bird Handling' do
  before do
    wipe_database

    DATA[:flocks].each do |flock_data|
      Flocks::Flock.create(flock_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    bird_data = DATA[:birds][1]
    flock = Flocks::Flock.first
    new_bird = flock.add_bird(bird_data)

    bird = Flocks::Bird.find(id: new_bird.id)
    _(bird.username).must_equal bird_data['username']
    _(bird.message).must_equal bird_data['message']
    _(bird.longitude).must_equal bird_data['longitude']
    _(bird.latitude).must_equal bird_data['latitude']
  end

  it 'SECURITY: should not use deterministic integers' do
    bird_data = DATA[:birds][1]
    flock = Flocks::Flock.first
    new_bird = flock.add_bird(bird_data)

    _(new_bird.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    bird_data = DATA[:birds][1]
    flock = Flocks::Flock.first
    new_bird = flock.add_bird(bird_data)
    stored_bird = app.DB[:birds].first

    _(stored_bird[:message_secure]).wont_equal new_bird.message
    _(stored_bird[:latitude_secure]).wont_equal new_bird.latitude
    _(stored_bird[:longitude_secure]).wont_equal new_bird.longitude
  end
end