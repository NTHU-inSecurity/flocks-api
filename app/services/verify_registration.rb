# frozen_string_literal: true

require 'http'

module Flocks
  ## Send email verfification email
  # params:
  #   - registration: hash with keys :username :email :verification_url
  class VerifyRegistration
    # Error for invalid registration details
    class InvalidRegistration < StandardError; end
    class EmailProviderError < StandardError; end

    def initialize(registration)
      @registration = registration
    end

    def mail_api_key = ENV.fetch('MAIL_API_KEY')
    def from_email = ENV.fetch('MAIL_SENDER')

    def call
      raise(InvalidRegistration, 'Username exists') unless username_available?
      raise(InvalidRegistration, 'Email already used') unless email_available?

      send_email_verification
    end

    def username_available?
      Account.first(username: @registration[:username]).nil?
    end

    def email_available?
      Account.first(email: @registration[:email]).nil?
    end

    def html_email
      <<~END_EMAIL
        <H1>Flocks App Registration Received</H1>
        <p>Please <a href="#{@registration[:verification_url]}">click here</a>
        to validate your email.
        You will be asked to set a password to activate your account.</p>
      END_EMAIL
    end

    def mail_json # rubocop:disable Metrics/MethodLength
      {
        sender: {
          name: 'Flocks',
          email: from_email
        },
        to: [
          {
            email: @registration[:email],
            name: 'User'
          }
        ],
        subject: 'Please verify your email address',
        htmlContent: html_email
      }
    end

    def send_email_verification
      response = HTTP.headers(
        'api-key' => mail_api_key,
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      ).post('https://api.brevo.com/v3/smtp/email', body: mail_json.to_json)

      raise EmailProviderError if response.status >= 300
    rescue EmailProviderError
      raise EmailProviderError
    rescue StandardError => e
      puts "Error: #{e.message}"
      raise(InvalidRegistration,
            'Could not send verification email; please check email address')
    end
  end
end
