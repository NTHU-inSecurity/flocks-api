# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test CreateFlock service' do
  before do
    wipe_database
  end

  it 'HAPPY: should create a new flock in the database' do
    flock_data = DATA[:flocks][1]
    new_flock = Flocks::CreateFlock.call(flock_data: flock_data)

    _(new_flock).must_be_instance_of Flocks::Flock
    _(new_flock.destination_url).must_equal flock_data['destination_url']
    
    _(new_flock.entrance_ticket).wont_be_nil
  end

  it 'BAD: should raise error for invalid data' do
    bad_flock_data = {}
    
    _(proc {
      Flocks::CreateFlock.call(flock_data: bad_flock_data)
    }).must_raise StandardError
  end
end