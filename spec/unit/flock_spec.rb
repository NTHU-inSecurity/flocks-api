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

  it 'SECURITY: should secure sensitive attributes' do
    flock_data = DATA[:flocks][1]
    flock = Flocks::Flock.create(flock_data)
    stored_flock = app.DB[:flocks].first

    _(stored_flock[:entrance_ticket_secure]).wont_equal flock.entrance_ticket
    _(stored_flock[:entrance_ticket_secure]).wont_equal flock.entrance_ticket_hashed
    _(stored_flock[:entrance_ticket_hashed]).wont_equal nil
  end

  it 'SECURITY: should search by hashed value' do
    flock_data = DATA[:flocks][1]
    flock = Flocks::Flock.create(flock_data)
    stored_flock = app.DB[:flocks].first

    pass_hashed = SecureDB.hash_ticket(flock.entrance_ticket)
    flock = Flocks::Flock.first(entrance_ticket_hashed: pass_hashed)

    _(stored_flock[:destination_url]).must_equal flock.destination_url
  end

end