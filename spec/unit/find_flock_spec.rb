# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test FindFlock service' do
  before do
    wipe_database
    
    DATA[:flocks].each do |flock_data|
      Flocks::Flock.create(flock_data)
    end
    
    @flock = Flocks::Flock.first
  end

  it 'HAPPY: should find an existing flock' do
    found = Flocks::FindFlock.call(id: @flock.id)
    
    _(found.id).must_equal @flock.id
    _(found.destination_url).must_equal @flock.destination_url
  end

  it 'BAD: should raise error if flock does not exist' do
    _(proc {
      Flocks::FindFlock.call(id: 'non_existent_id')
    }).must_raise Flocks::FindFlock::NotFoundError
  end
end