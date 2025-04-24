# frozen_string_literal: true

require 'rbnacl'
require 'base64'

# Encrypt and Decrypt from Database
class SecureDB
  # custom error class
  class NoDbKeyError < StandardError; end

  # Generate key for Rake tasks (typically not called at runtime)
  def self.generate_key
    key = RbNaCl::Random.random_bytes(RbNaCl::SecretBox.key_bytes)
    Base64.strict_encode64 key
  end

  def self.generate_hash_salt
    salt = RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
    Base64.strict_encode64 salt
  end

  def self.setup(base_key, base_salt)
    raise NoDbKeyError unless base_key
    raise NoDbKeyError unless base_salt

    @key = Base64.strict_decode64(base_key)
    @salt = Base64.strict_decode64(base_salt)
  end

  # Encrypt or else return nil if data is nil
  def self.encrypt(plaintext)
    return nil unless plaintext

    simple_box = RbNaCl::SimpleBox.from_secret_key(@key)
    ciphertext = simple_box.encrypt(plaintext)
    Base64.strict_encode64(ciphertext)
  end

  # Decrypt or else return nil if database value is nil already
  def self.decrypt(ciphertext64)
    return nil unless ciphertext64

    ciphertext = Base64.strict_decode64(ciphertext64)
    simple_box = RbNaCl::SimpleBox.from_secret_key(@key)
    simple_box.decrypt(ciphertext).force_encoding(Encoding::UTF_8)
  end

  # generate entrance passcode
  def self.generate_ticket
    ticket = RbNaCl::Random.random_bytes(RbNaCl::SecretBox.key_bytes)
    Base64.strict_encode64 ticket
  end

  def self.hash_ticket(ticket)
    hashed_ = RbNaCl::PasswordHash.scrypt(
      ticket,
      @salt,
      2**20,
      2**24,
      64
    )

    Base64.strict_encode64 hashed_
  end
end
