# frozen_string_literal: true

require 'http'

module Flocks
  # Authenticate an SSO acocunt by finding or creating one based on Google data
  class AuthenticateSso
    def call(access_token)
      google_account = get_google_account(access_token)
      sso_account = find_or_create_sso_account(google_account)

      AuthorizedAccount.new(sso_account, AuthScope::EVERYTHING).to_h
    end

    def get_google_account(access_token)
      g_response = HTTP.auth("Bearer #{access_token}").headers(accept: 'application/json').get(ENV.fetch('GOOGLE_ACCOUNT_URL'))

      raise unless g_response.status == 200

      account = GoogleAccount.new(JSON.parse(g_response))
      { username: account.username, email: account.email }
    end

    def find_or_create_sso_account(account_data)
      Account.first(email: account_data[:email]) ||
        Account.create_google_account(account_data)
    end
  end
end
