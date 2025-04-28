# frozen_string_literal: true

module Flocks
  # Service object to list all flocks
  class ListFlocks
    def self.call
      Flock.all
    end
  end
end