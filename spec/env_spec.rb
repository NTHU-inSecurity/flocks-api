# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test environment setup' do
  it 'HAPPY: should set RACK_ENV to test' do
    _(ENV['RACK_ENV']).must_equal 'test'
  end

  it 'HAPPY: should have database connection' do
    _(Flocks::Api.DB).wont_be_nil
    _(Flocks::Api.DB.tables).must_be_kind_of Array
  end

  it 'HAPPY: should handle DATABASE_URL not found in ENV' do
    _(ENV['DATABASE_URL']).must_be_nil
    
    _(Flocks::Api.DB).wont_be_nil
  end
end