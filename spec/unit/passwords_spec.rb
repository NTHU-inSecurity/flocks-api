# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Password Digestion' do
  it 'SECURITY: create password digests safely, hiding raw password' do
    password = 'supersecret password'
    digest = Flocks::Password.digest(password)

    _(digest.to_s.match?(password)).must_equal false
  end

  it 'SECURITY: successfully checks correct password from stored digest' do
    password = 'supersecret password'
    digest_s = Flocks::Password.digest(password).to_s

    stored_password = Flocks::Password.from_digest(digest_s)
    _(stored_password.correct?(password)).must_equal true
  end

  it 'SECURITY: successfully detects incorrect password from stored digest' do
    password1 = 'supersecret password'
    password2 = 'another password'
    digest_s1 = Flocks::Password.digest(password1).to_s

    true_password = Flocks::Password.from_digest(digest_s1)
    _(true_password.correct?(password2)).must_equal false
  end
end
