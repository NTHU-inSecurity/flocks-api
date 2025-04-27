# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test UpdateBirdInFlock service' do
  before do
    wipe_database
    
    flock_data = DATA[:flocks][1]
    @flock = Flocks::Flock.create(flock_data)
    
    bird_data = DATA[:birds][1]
    @bird = @flock.add_bird(bird_data)
  end

  it 'HAPPY: should update bird information' do
    update_data = {
      'message' => 'Updated message',
      'latitude' => 25.123456,
      'longitude' => 121.654321
    }
    
    updated_bird = Flocks::UpdateBirdInFlock.call(
      flock_id: @flock.id,
      username: @bird.username,
      update_data: update_data
    )
    
    _(updated_bird.id).must_equal @bird.id
    _(updated_bird.message).must_equal update_data['message']
    _(updated_bird.latitude).must_equal update_data['latitude']
    _(updated_bird.longitude).must_equal update_data['longitude']
  end

  it 'BAD: should raise error if bird does not exist' do
    update_data = { 'message' => 'Updated message' }
    
    _(proc {
      Flocks::UpdateBirdInFlock.call(
        flock_id: @flock.id,
        username: 'non_existent_username',
        update_data: update_data
      )
    }).must_raise Flocks::UpdateBirdInFlock::NotFoundError
  end
end