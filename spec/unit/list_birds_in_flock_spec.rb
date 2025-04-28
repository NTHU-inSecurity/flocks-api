# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test ListBirdsInFlock service' do
  before do
    wipe_database
    
    # create a flock
    flock_data = DATA[:flocks][1]
    @flock = Flocks::Flock.create(flock_data)
    
    # create birds in the flock
    DATA[:birds].each do |bird_data|
      @flock.add_bird(bird_data)
    end
  end

  it 'HAPPY: should return all birds in a flock' do
    birds = Flocks::ListBirdsInFlock.call(flock_id: @flock.id)
    
    _(birds.count).must_equal DATA[:birds].count
    
    # check if each bird in the list is an instance of Flocks::Bird
    birds.each do |bird|
      _(bird).must_be_instance_of Flocks::Bird
      _(bird.flock_id).must_equal @flock.id
    end
  end

  it 'BAD: should raise error if flock does not exist' do
    _(proc {
      Flocks::ListBirdsInFlock.call(flock_id: 'non_existent_id')
    }).must_raise Flocks::ListBirdsInFlock::NotFoundError
  end
end