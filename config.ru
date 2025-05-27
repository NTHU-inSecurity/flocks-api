# frozen_string_literal: true

require './require_app'
require_app

# run faye server to handle websocket connections
require 'faye'
use Faye::RackAdapter, mount: '/faye', timeout: 25

run Flocks::Api.freeze.app
