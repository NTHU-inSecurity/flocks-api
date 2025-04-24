# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test SecureDB Class' do
  it 'SECURITY: should encrypt text' do
    test_data = 'born to eat cheese, forced to lock in'
    text_sec = SecureDB.encrypt(test_data)
    _(text_sec).wont_equal test_data
  end

  it 'SECURITY: should decrypt encrypted ASCII' do
    test_data = "test data ~ 1 & \n"
    text_sec = SecureDB.encrypt(test_data)
    test_decrypted = SecureDB.decrypt(text_sec)
    _(test_decrypted).must_equal test_data
  end

  it 'SECURITY: should decrypt non-ASCII characters' do
    test_data = 'слава Украине'
    text_sec = SecureDB.encrypt(test_data)
    test_decrypted = SecureDB.decrypt(text_sec)
    _(test_decrypted).must_equal test_data
  end
end
