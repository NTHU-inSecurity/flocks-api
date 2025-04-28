# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test ListFlocks service' do
  before do
    wipe_database
    
    # create a flock
    DATA[:flocks].each do |flock_data|
      Flocks::Flock.create(flock_data)
    end
  end

  it 'HAPPY: should return a list of all flocks' do
    flocks = Flocks::ListFlocks.call
    
    _(flocks.count).must_equal DATA[:flocks].count
    _(flocks).must_be_kind_of Sequel::Dataset
    
    # check if each flock in the list is an instance of Flocks::Flock
    flocks.each do |flock|
      _(flock).must_be_instance_of Flocks::Flock
    end
  end

  it 'HAPPY: should return empty list if no flocks exist' do
    wipe_database  # empty the database
    
    flocks = Flocks::ListFlocks.call
    
    _(flocks.count).must_equal 0
  end
end