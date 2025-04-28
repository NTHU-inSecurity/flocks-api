# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddBirdToFlock service' do
  before do
    wipe_database
    
    DATA[:flocks].each do |flock_data|
      Flocks::Flock.create(flock_data)
    end
    
    @flock = Flocks::Flock.first
  end

  it 'HAPPY: should add a new bird to a flock' do
    bird_data = DATA[:birds][1]
    
    new_bird = Flocks::AddBirdToFlock.call(
      flock_id: @flock.id,
      bird_data: bird_data
    )

    _(new_bird).must_be_instance_of Flocks::Bird
    _(new_bird.username).must_equal bird_data['username']
    _(new_bird.message).must_equal bird_data['message']
    _(new_bird.latitude).must_equal bird_data['latitude']
    _(new_bird.longitude).must_equal bird_data['longitude']
    
    # bird should be added to the flock
    _(@flock.birds.count).must_equal 1
    _(@flock.birds.first.id).must_equal new_bird.id
  end

  it 'BAD: should raise error for non-existent flock ID' do
    bird_data = DATA[:birds][1]
    
    _(proc {
      Flocks::AddBirdToFlock.call(
        flock_id: 'non_existent_id',
        bird_data: bird_data
      )
    }).must_raise StandardError
  end
end