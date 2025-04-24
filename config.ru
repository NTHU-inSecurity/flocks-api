# frozen_string_literal: true

require './require_app'
require_app

run Flocks::Api.freeze.app
