# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Flock Handling' do
  before do
    wipe_database
  end

  it 'HAPPY: should retrieve correct data from database' do
    flock_data = DATA[:flocks][1]
    flock = Flocks::Flock.create(flock_data)

    _(flock.destination_url).must_equal flock_data['destination_url']
  end

  it 'SECURITY: should not use deterministic integers' do
    flock_data = DATA[:flocks][1]
    flock = Flocks::Flock.create(flock_data)

    _(flock.id.is_a?(Numeric)).must_equal false
  end
end
