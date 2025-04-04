# frozen_string_literal: true

require 'json'
require 'rbnacl'
require 'base64'

require_relative 'bird'

module Flocks
  STORE_DIR = 'db/local'
  # Holds a full secret url
  class Flock
    def initialize(flock)
      @flock_id = flock['flock_id'] || new_flock_id
      @destination_url = flock['destination_url']
      @birds = (flock['birds'] || []).map { |bird_data| Bird.new(bird_data) }
    end

    attr_reader :flock_id, :destination_url

    def to_json(options = {})
      JSON(
        {
          type: 'flock',
          flock_id:,
          destination_url:,
          birds: @birds.map(&:to_h)
        },
        options
      )
    end

    def self.setup
      FileUtils.mkdir_p(Flocks::STORE_DIR)
    end

    def save
      File.write("#{Flocks::STORE_DIR}/#{flock_id}.txt", to_json)
    end

    def self.find(find_flock_id)
      flock_file = File.read("#{Flocks::STORE_DIR}/#{find_flock_id}.txt")
      Flock.new(JSON.parse(flock_file))
    end

    def self.all
      Dir.glob("#{Flocks::STORE_DIR}/*.txt").map do |file|
        File.basename(file, '.txt')
      end
    end

    private

    def new_flock_id
      timestamp = Time.now.to_f.to_s
      # compute the SHA-256 digest of the timestamp
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
