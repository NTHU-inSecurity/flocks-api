# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test FindBird service' do
  before do
    wipe_database
    
    # create a flock
    flock_data = DATA[:flocks][1]
    @flock = Flocks::Flock.create(flock_data)
    
    # create a bird in the flock
    bird_data = DATA[:birds][1]
    @bird = @flock.add_bird(bird_data)
  end

  it 'HAPPY: should find an existing bird by username' do
    found = Flocks::FindBird.call(
      flock_id: @flock.id,
      username: @bird.username
    )
    
    _(found.id).must_equal @bird.id
    _(found.username).must_equal @bird.username
    _(found.message).must_equal @bird.message
  end

  it 'BAD: should raise error if bird does not exist' do
    _(proc {
      Flocks::FindBird.call(
        flock_id: @flock.id,
        username: 'non_existent_username'
      )
    }).must_raise Flocks::FindBird::NotFoundError
  end
end